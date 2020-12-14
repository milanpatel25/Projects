#include "cEditorFrame.h"

wxBEGIN_EVENT_TABLE(cEditorFrame, wxMDIChildFrame)
EVT_SLIDER(20001, cEditorFrame::OnZoomChange)
wxEND_EVENT_TABLE()

cEditorFrame::cEditorFrame(wxMDIParentFrame* parent, wxString name) : wxMDIChildFrame(parent, wxID_ANY, name)
{
	canvas = new cCanvas(this);
	statusBar = this->CreateStatusBar(2, wxSTB_DEFAULT_STYLE, wxID_ANY);
	zoomSlider = new wxSlider(statusBar, 20001, 8, 1, 32);
}

cEditorFrame::~cEditorFrame()
{
}

void cEditorFrame::OnZoomChange(wxCommandEvent& evt)
{
	statusBar->SetStatusText(wxString("Zoom: ") << zoomSlider->GetValue(), 1);
	canvas->SetPixelSize(zoomSlider->GetValue());
	evt.Skip();
}

void cEditorFrame::SetColour(int c)
{
	canvas->SetColour(c);
}

bool cEditorFrame::Save(wxString sFileName)
{
	return false;
}

bool cEditorFrame::Open(wxString sFileName)
{
	return false;
}

bool cEditorFrame::New(int r, int c)
{
	delete[] m_pSprite;
	m_pSprite = new unsigned char[r * c]{ 0 };
	canvas->SetSpriteData(r, c, m_pSprite);
	//sprBase = olcSprite(c, r);
	return false;
}
