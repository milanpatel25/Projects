#include "cMain.h"
#include "string"

wxBEGIN_EVENT_TABLE(cMain, wxMDIParentFrame)
EVT_MENU(10001, cMain::menuNew)
EVT_MENU(10002, cMain::menuOpen)
EVT_MENU(10003, cMain::menuSave)
EVT_MENU(10004, cMain::menuExit)
wxEND_EVENT_TABLE()

cMain::cMain() : wxMDIParentFrame(nullptr, wxID_ANY, "ANDY", wxPoint(100, 100), wxSize(800, 600))
{
	menuBar = new wxMenuBar();
	this->SetMenuBar(menuBar);

	wxMenu* menuFile = new wxMenu();
	menuFile->Append(10001, "New");
	menuFile->Append(10002, "Open");
	menuFile->Append(10003, "Save");
	menuFile->Append(10004, "Exit");

	menuBar->Append(menuFile, "File");

	toolBar = this->CreateToolBar(wxTB_HORIZONTAL, wxID_ANY);

	wxColour palette[16];
	palette[0] = wxColour(0, 0, 0);
	palette[1] = wxColour(0, 0, 128);
	palette[2] = wxColour(0, 128, 0);
	palette[3] = wxColour(0, 128, 128);
	palette[4] = wxColour(128, 0, 0);
	palette[5] = wxColour(128, 0, 128);
	palette[6] = wxColour(128, 128, 0);
	palette[7] = wxColour(192, 192, 192);
	palette[8] = wxColour(128, 128, 128);
	palette[9] = wxColour(0, 0, 255);
	palette[10] = wxColour(0, 255, 0);
	palette[11] = wxColour(0, 255, 255);
	palette[12] = wxColour(255, 0, 0);
	palette[13] = wxColour(255, 0, 255);
	palette[14] = wxColour(255, 255, 0);
	palette[15] = wxColour(255, 255, 255);

	for (int i = 0; i < 16; i++) {
		wxButton* b = new wxButton(toolBar, 10100 + i, "", wxDefaultPosition, wxSize(40, 24), 0);
		b->SetBackgroundColour(palette[i]);
		b->Connect(wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler(cMain::selectColour), nullptr, this);
		toolBar->AddControl(b);
	}

	wxButton* b = new wxButton(toolBar, 10100 + 16, "Alpha", wxDefaultPosition, wxDefaultSize, 0);
	b->Connect(wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler(cMain::selectColour), nullptr, this);
	toolBar->AddControl(b);
	toolBar->Realize();

}

cMain::~cMain()
{

}

void cMain::menuNew(wxCommandEvent& evt)
{
	cEditorFrame *f = new cEditorFrame(this, "Test");
	f->New(400, 400);
	f->Show();
	evt.Skip();
}

void cMain::menuOpen(wxCommandEvent& evt)
{
}

void cMain::menuSave(wxCommandEvent& evt)
{
}

void cMain::menuExit(wxCommandEvent& evt)
{
	Close();
	evt.Skip();
}

void cMain::selectColour(wxCommandEvent& evt)
{
	int colour = evt.GetId() - 10100;
	if (GetActiveChild() != nullptr) {
		((cEditorFrame*)GetActiveChild())->SetColour(colour);
	}
}


//wxBEGIN_EVENT_TABLE(cMain, wxFrame)
//
//wxEND_EVENT_TABLE()
//
//cMain::cMain() : wxFrame(nullptr, wxID_ANY, "ANDY", wxPoint(100, 100), wxSize(800, 600))
//{
//	btn = new wxButton * [heightSize * widthSize];
//	wxGridSizer* grid = new wxGridSizer(heightSize, widthSize, 0, 0);
//	field = new int[heightSize * widthSize];
//
//	for (int x = 0; x < widthSize; x++) {
//		for (int y = 0; y < heightSize; y++) {
//			btn[y * widthSize + x] = new wxButton(this, 10000 + (y * widthSize + x));
//			grid->Add(btn[y * widthSize + x], 1, wxEXPAND | wxALL);
//			btn[y * widthSize + x]->Bind(wxEVT_COMMAND_BUTTON_CLICKED, &cMain::OnButtonClicked, this);
//			field[y * widthSize + x] = 0;
//		}
//	}
//	this->SetSizer(grid);
//	grid->Layout();
//}
//
//cMain::~cMain()
//{
//	delete[]btn;
//	delete[]field;
//}
//
//void cMain::OnButtonClicked(wxCommandEvent& evt)
//{
//	int x = (evt.GetId() - 10000) % widthSize;
//	int y = (evt.GetId() - 10000) / widthSize;
//	if (firstClick) {
//		populateBoard(x, y);
//	}
//	btn[y * widthSize + x]->Enable(false);
//	btn[y * widthSize + x]->SetLabel(std::to_string(field[y * widthSize + x]));
//	//for (int x = 0; x < widthSize; x++) {
//	//	for (int y = 0; y < heightSize; y++) {
//	//		int bombcount = field[y * widthSize + x];
//	//		btn[y * widthSize + x]->SetLabel(std::to_string(bombcount));
//	//	}
//	//}
//	evt.Skip();
//}
//
//bool cMain::validCell(int x, int y) {
//	if (x < widthSize && y < heightSize && x >= 0 && y >= 0) {
//		return true;
//	}
//	else {
//		return false;
//	}
//}
//
//void cMain::populateBoard(int x, int y) {
//	int mines = 30;
//
//	while (mines) {
//		int rx = rand() % widthSize;
//		int ry = rand() % heightSize;
//
//		if ((rx != x && ry != y) && field[ry * widthSize + rx] != -1) {
//			field[ry * widthSize + rx] = -1;
//			mines--;
//		}
//	}
//
//	for (int i = 0; i < 100; i++) {
//		int fx = i % widthSize;
//		int fy = i / widthSize;
//		if (field[fy * widthSize + fx] != -1) {
//			int numberOfBombs = 0;
//			for (int sx = fx-1; sx < fx+2; sx++) {
//				for (int sy = fy-1; sy < fy+2; sy++) {
//					if (validCell(sx,sy) && field[sy * widthSize + sx] == -1) {
//						numberOfBombs++;
//					}
//				}
//			}
//			field[fy * widthSize + fx] = numberOfBombs;
//		}
//
//
//	}
//	firstClick = false;
//}

