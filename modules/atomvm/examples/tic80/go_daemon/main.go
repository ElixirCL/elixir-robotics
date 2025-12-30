package main

import (
	"bufio"
	"io"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/micmonay/keybd_event"
	"go.bug.st/serial"
)

type KeyAction struct {
	Key      int
	Duration time.Duration // 0 = tap, >0 = hold for this duration
}

type State struct {
	prevPotValue  int
	prevPotTime   time.Time
	keyActionChan chan KeyAction
}

var appLogger = log.New(os.Stdout, "[APP] ", log.LstdFlags|log.Lshortfile)

func main() {
	portName := "/dev/ttyUSB0"
	baudRate := 115200

	if len(os.Args) > 1 {
		portName = os.Args[1]
	}

	appLogger.Printf("Attempting to open serial port: %s at %d baud...\n", portName, baudRate)

	mode := &serial.Mode{
		BaudRate: baudRate,
	}

	port, err := serial.Open(portName, mode)
	if err != nil {
		appLogger.Fatalf("Failed to open serial port %s: %v\n", portName, err)
	}
	defer func() {
		appLogger.Println("Closing serial port...")
		if err := port.Close(); err != nil {
			appLogger.Printf("Error closing serial port: %v\n", err)
		}
	}()

	appLogger.Printf("Successfully opened serial port %s. Starting goroutines...\n", portName)

	keyActionChan := make(chan KeyAction, 10)
	serialWriteChan := make(chan []byte, 10)
	serialReadLinesChan := make(chan string, 100)

	state := State{
		prevPotValue:  -1,
		prevPotTime:   time.Now(),
		keyActionChan: keyActionChan,
	}

	go keyboardWorker(keyActionChan)

	go serialReaderGoroutine(port, serialReadLinesChan)

	go serialWriterGoroutine(port, serialWriteChan)

	go stdinProcessorGoroutine(&state, serialWriteChan)

	go func() {
		var button1Pressed bool
		var button2Pressed bool

		for line := range serialReadLinesChan {
			appLogger.Printf("[Serial Data] Received: %s\n", line)
			action, newButton1Pressed, newButton2Pressed := getSerialKeyAction(&state, line, button1Pressed, button2Pressed)
			button1Pressed = newButton1Pressed
			button2Pressed = newButton2Pressed

			if action.Key != 0 {
				select {
				case state.keyActionChan <- action:
				default:
					appLogger.Printf("Warning: keyActionChan full, dropping action: %+v", action)
				}
			}
		}
		appLogger.Println("[Serial Processor] Exiting.")
	}()

	select {}
}

func serialReaderGoroutine(port serial.Port, outputChan chan<- string) {
	appLogger.Println("[Serial Reader] Starting to read from serial port...")
	reader := bufio.NewReader(port)
	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			appLogger.Printf("[Serial Reader] Error reading from serial port: %v\n", err)
			if err == io.EOF || strings.Contains(err.Error(), "device disconnected") || strings.Contains(err.Error(), "no such file") {
				appLogger.Println("[Serial Reader] Device likely disconnected. Pausing for 5s before retrying read.")
				time.Sleep(5 * time.Second)
			} else {
				time.Sleep(100 * time.Millisecond)
			}
			continue
		}

		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		outputChan <- line
	}
}

func serialWriterGoroutine(port serial.Port, inputChan <-chan []byte) {
	appLogger.Println("[Serial Writer] Starting to write to serial port...")
	for data := range inputChan {
		n, err := port.Write(data)
		if err != nil {
			appLogger.Printf("[Serial Writer] Error writing %q to serial: %v\n", data, err)
		} else {
			appLogger.Printf("[Serial Writer] Wrote %d bytes to serial: %q\n", n, data)
		}
	}
	appLogger.Println("[Serial Writer] Exiting.")
}

func stdinProcessorGoroutine(state *State, serialWriteChan chan<- []byte) {
	appLogger.Println("[Stdin Processor] Reading from stdin. Type 'serial:<message>' to send to serial.")
	appLogger.Println("[Stdin Processor] Example: serial:AT\\r\\n")
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		line := scanner.Text()
		appLogger.Printf("[Stdin Processor] Received from stdin: %q\n", line)
		processStdinCommand(state, line, serialWriteChan)
	}
	if err := scanner.Err(); err != nil {
		appLogger.Printf("[Stdin Processor] Error reading stdin: %v\n", err)
	}
	appLogger.Println("[Stdin Processor] Stdin closed or error. Exiting.")
}

func processStdinCommand(state *State, input string, serialWriteChan chan<- []byte) {
	if after, ok := strings.CutPrefix(input, ">event:"); ok {
		switch after {
		case "explode":
			msgBytes := []byte("red")
			select {
			case serialWriteChan <- msgBytes:
				appLogger.Printf("[Stdin Cmd] Queued message for serial: %q\n", msgBytes)
			default:
				appLogger.Println("[Stdin Cmd] Serial write channel full, dropping message.")
			}
		case "score_milestone":
			msgBytes := []byte("blue")
			select {
			case serialWriteChan <- msgBytes:
				appLogger.Printf("[Stdin Cmd] Queued message for serial: %q\n", msgBytes)
			default:
				appLogger.Println("[Stdin Cmd] Serial write channel full, dropping message.")
			}
		}
	} else {
		appLogger.Printf("[Stdin Cmd] Unrecognized stdin command: %q\n", input)
	}
}

func getSerialKeyAction(state *State, input string, button1Pressed bool, button2Pressed bool) (KeyAction, bool, bool) {
	if strings.Contains(input, "Button 1:") {
		if strings.Contains(input, "pressed") && !button1Pressed {
			appLogger.Println("[Serial Data] Button 1 pressed.")
			return KeyAction{Key: keybd_event.VK_X, Duration: 0}, true, button2Pressed
		} else if strings.Contains(input, "released") {
			appLogger.Println("[Serial Data] Button 1 released.")
			return KeyAction{}, false, button2Pressed
		}
		return KeyAction{}, button1Pressed, button2Pressed
	}

	if strings.Contains(input, "Button 2:") {
		if strings.Contains(input, "pressed") && !button2Pressed {
			appLogger.Println("[Serial Data] Button 2 pressed.")
			return KeyAction{Key: keybd_event.VK_Z, Duration: 0}, button1Pressed, true
		} else if strings.Contains(input, "released") {
			appLogger.Println("[Serial Data] Button 2 released.")
			return KeyAction{}, button1Pressed, false
		}
		return KeyAction{}, button1Pressed, button2Pressed
	}

	if strings.HasPrefix(input, "Potentiometer:") {
		parts := strings.Split(input, " ")
		if len(parts) < 2 {
			return KeyAction{}, button1Pressed, button2Pressed
		}

		rawStr := strings.TrimPrefix(parts[1], "raw=")
		rawVal, err := strconv.Atoi(rawStr)
		if err != nil {
			return KeyAction{}, button1Pressed, button2Pressed
		}

		if state.prevPotValue == -1 {
			state.prevPotValue = rawVal
			state.prevPotTime = time.Now()
			return KeyAction{}, button1Pressed, button2Pressed
		}

		diff := rawVal - state.prevPotValue

		now := time.Now()
		if now.Sub(state.prevPotTime) <= 50*time.Millisecond {
			return KeyAction{}, button1Pressed, button2Pressed
		}

		var key int
		absDiff := diff
		if diff > 0 {
			key = keybd_event.VK_RIGHT
		} else if diff < 0 {
			key = keybd_event.VK_LEFT
			absDiff = -diff
		} else {
			return KeyAction{}, button1Pressed, button2Pressed
		}

		if absDiff < 50 {
			return KeyAction{}, button1Pressed, button2Pressed
		}

		duration := calculateDuration(absDiff)
		appLogger.Printf("[Serial Data] Potentiometer changed by %d. Sending key %v for %v.\n", diff, key, duration)

		state.prevPotValue = rawVal
		state.prevPotTime = now

		return KeyAction{Key: key, Duration: duration}, button1Pressed, button2Pressed
	}

	return KeyAction{}, button1Pressed, button2Pressed
}

func keyboardWorker(ch <-chan KeyAction) {
	appLogger.Println("[Keyboard Worker] Starting...")
	kb, err := keybd_event.NewKeyBonding()
	if err != nil {
		appLogger.Fatalf("Fatal: failed to create KeyBonding in worker: %v", err)
		return
	}

	for action := range ch {
		appLogger.Printf("[Keyboard Worker] Performing action: %+v\n", action)
		if action.Duration == 0 {
			kb.SetKeys(action.Key)
			kb.Launching()
		} else {
			kb.SetKeys(action.Key)
			kb.Press()
			time.Sleep(action.Duration)
			kb.Release()
		}
	}
	appLogger.Println("[Keyboard Worker] Exiting.")
}

func calculateDuration(diff int) time.Duration {
	switch {
	case diff >= 1000:
		return 500 * time.Millisecond
	case diff >= 500:
		return 300 * time.Millisecond
	case diff >= 250:
		return 200 * time.Millisecond
	case diff >= 100:
		return 100 * time.Millisecond
	case diff >= 50:
		return 50 * time.Millisecond
	default:
		return 0
	}
}
