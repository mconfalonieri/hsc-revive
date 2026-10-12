package main

import (
	"fmt"
	"os"

	tea "charm.land/bubbletea/v2"
	"github.com/charmbracelet/log"
)

type model struct {
	Status int
}

func (m model) Init() tea.Cmd {
	return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		if msg.String() == "q" {
			return m, tea.Quit
		}
	}
	return m, nil
}

func (m model) View() tea.View {
	return tea.NewView("Press 'q' to exit.")
}

func initialModel() model {
	return model{}
}

func initializeLog() {
	f, err := tea.LogToFile("hsc-revive.log", "debug")
	if err != nil {
		fmt.Println("Errore nell'apertura del file di log:", err)
		os.Exit(1)
	}
	defer f.Close()
	log.SetOutput(f)
	log.SetReportTimestamp(true)
}

func main() {
	initializeLog()
	log.Info("Starting hsc-revive")
	p := tea.NewProgram(initialModel())
	if _, err := p.Run(); err != nil {
		log.Error("Errore nell'esecuzione dell'app", "err", err)
		os.Exit(1)
	}
}
