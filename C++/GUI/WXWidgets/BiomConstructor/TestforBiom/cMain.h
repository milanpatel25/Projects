#pragma once
#include "wx/wx.h"
#include "cEditorFrame.h"


class cMain : public wxMDIParentFrame
{
public:
	cMain();
	~cMain();

private:
	wxToolBar* toolBar = nullptr;
	wxMenuBar* menuBar = nullptr;

	void menuNew(wxCommandEvent &evt);
	void menuOpen(wxCommandEvent &evt);
	void menuSave(wxCommandEvent &evt);
	void menuExit(wxCommandEvent &evt);

	void selectColour(wxCommandEvent& evt);

	wxDECLARE_EVENT_TABLE();
};

//class cMain : public wxFrame
//{
//public:
//	cMain();
//	~cMain();
//
//public:
//	int heightSize = 10;
//	int widthSize = 10;
//	wxButton** btn;
//	int* field = nullptr;
//	bool firstClick = true;
//
//public:
//	void OnButtonClicked(wxCommandEvent& evt);
//	bool validCell(int x, int y);
//	void populateBoard(int x, int y);
//
//	wxDECLARE_EVENT_TABLE();
//};
