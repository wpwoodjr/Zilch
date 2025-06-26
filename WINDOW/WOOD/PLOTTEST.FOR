	implicit integer (a-z)

	call wplotinit
	Call WViewPort(30.0, 120.0, 20.0, 80.0)
	Call WWindow(-180.0, 180.0, -120.0, 120.0)
	Call WMove(0.0, -20.0)
	Call WTextDir(0.0)
	Call WCHeight(3.8)
	Call WTextOrg(5)
	Call WCAspect(0.70)
	Call WNewColor(3)
	If ( WFont(12).eq.12 ) Continue
	Call WPlotText('This is an ONLINE graphics link')

* Drawing a Bucky Badger!

	If ( WFont(19).eq.19 ) then
	  Call WCHeight(8.0)
	  Call WViewPort(0.0, 150.0, 0.0, 100.0)
	  Call WWindow  (0.0, 150.0, 0.0, 100.0)
	  Call WMove(135.0, 90.0)
	  Call WPlotText('"')
	End If

	call WPlotExit
	end
