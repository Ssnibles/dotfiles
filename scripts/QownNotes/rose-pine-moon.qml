import QtQml 2.0
import QOwnNotesTypes 1.0

Script {
    function init() {
        script.addStyleSheet(`
  * {
                font-family: "JetBrainsMono Nerd Font";
            }

            QWidget {
                background-color: #232136;
                color: #e0def4;
            }

            QTreeWidget#noteTreeWidget, QTextEdit, QPlainTextEdit {
                background-color: #2a273f;
                color: #e0def4;
                border: none;
            }

            QTreeView::item:selected, QListView::item:selected {
                color: #e0def4;
                background-color: #393552;
            }

            QLineEdit, QTextEdit, QPlainTextEdit {
                background-color: #2a273f;
                color: #e0def4;
                selection-background-color: #44415a;
                selection-color: #e0def4;
                border: 1px solid #44415a;
                padding: 2px;
            }

            QToolBar, QMenuBar, QMenu {
                background-color: #2a273f;
                color: #e0def4;
                border: none;
            }

            QMenu::item:selected, QMenuBar::item:selected {
                background-color: #393552;
            }

            QPushButton {
                background-color: #393552;
                color: #e0def4;
                border: 1px solid #44415a;
                padding: 5px;
                border-radius: 3px;
            }

            QPushButton:hover {
                background-color: #44415a;
            }

            QScrollBar {
                background-color: #2a273f;
                width: 12px;
                height: 12px;
            }

            QScrollBar::handle {
                background-color: #393552;
                border-radius: 6px;
                min-height: 20px;
            }

            QScrollBar::add-line, QScrollBar::sub-line {
                background-color: transparent;
            }

            QTabWidget::pane {
                border: 1px solid #44415a;
            }

            QTabBar::tab {
                background-color: #2a273f;
                color: #e0def4;
                padding: 5px 10px;
                border-top-left-radius: 3px;
                border-top-right-radius: 3px;
            }

            QTabBar::tab:selected {
                background-color: #393552;
            }

            a {
                color: #c4a7e7;
            }

            code {
                background-color: #2a273f;
                color: #9ccfd8;
                padding: 2px 4px;
                border-radius: 3px;
            }

            ::selection {
                background-color: #44415a;
                color: #e0def4;
            }

            QToolTip {
                background-color: #2a273f;
                color: #e0def4;
                border: 1px solid #44415a;
                padding: 2px;
            }
                 `);
    }
}
