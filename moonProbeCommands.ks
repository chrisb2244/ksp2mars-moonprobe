declare function getWinchAndHook {
	// Get the winch PartModule.
	// Make the assumption that there is only one winch (or that we want the first!)
	set Winch to ship:partsdubbed("KAS.Winch2")[0]:getmodule("KASModuleWinch").
	set Hook to ship:partsdubbed("KAS.Hook.Harpoon")[0]:getmodule("KASModuleHarpoon").
	
	// Test the modules were found.
	if Winch:Name = "KasModuleWinch" and Hook:Name = "KASModuleHarpoon" {
		// Success - do nothing.
		print "Success!".
	} else {
		print "Uh-oh - couldn't find the right partmodules".
	}.
}

getWinchAndHook().
