// Get rid of lazy globals!
// Who wants this anyway?!
@LAZYGLOBAL off.

// This function gets the hook and winch variables.
// Takes no parameters.
// Returns a list of (1, Winch, Hook) or 0, where 0 indicates a failure.
// 0 is the default return value so I choose to explicitly return something else and treat 0 as an error.
declare function getWinchAndHook {
	// Get the winch PartModule.
	// Make the assumption that there is only one winch (or that we want the first!)
	declare local Winch to ship:partsdubbed("KAS.Winch2")[0]:getmodule("KASModuleWinch").
	declare local Hook to ship:partsdubbed("KAS.Hook.Harpoon")[0]:getmodule("KASModuleHarpoon").
	
	// Test the modules were found.
	if defined Winch and defined Hook {
		// Success
		return list(1, Winch, Hook).
	} else {
		// Failed. Maybe try other things?
		print "Uh-oh - couldn't find the right partmodules".
		return 0.
	}.
}.

// This function detaches the hook from the ground.
// Takes one optional parameter, 'Hook'.
declare function detachFromGround {
	// Get the value returned for Hook from the getWinchAndHook function, if it is not passed to this function.
	declare parameter Hook is getWinchAndHook()[2].

	// Check the state. To detach, the state should be "Ground attached"
	if Hook:GetField("State") = "Ground attached" {
		// Call the detach event.
		Hook:DoEvent("Detach").
		return 1.
	} else {
		// The hook isn't attached to the ground. Return 0.
		return 0.
	}
}.

// This function detaches the hook then retracts it. This presumably is more useful.
// Takes three optional parameters, 'WaitForRetract' (default true), 'Winch' and 'Hook'.
declare function detachAndRetract {
	declare parameter WaitForRetract is True.
	declare parameter Winch is getWinchAndHook()[1].
	declare parameter Hook is getWinchAndHook()[2].
	
	if detachFromGround(Hook) {
		// If here, the hook was just detached successfully.
		if Winch:GetField("Head State") = "Plugged(Docked)" {
			Winch:DoEvent("Plug Mode"). // Change the mode from 'docked' to 'undocked'. If the mode is docked, it won't retract properly.
		}.
		Winch:DoEvent("Retract").
		if WaitForRetract {
			print "Waiting for the harpoon to fully retract".
			declare local timeout to 0.
			until Winch:GetField("Head State") = "Locked" {
				wait 1.
				set timeout to timeout + 1.
				if timeout > 30 {
					// It could still be returning, but more likely, the head is stuck.
					// We can try to troubleshoot this in more advanced versions of this code.
					print "Harpoon head is probably stuck - retract timed out".
					return 2.
				}
			}
		} else {
			return 1.
		}.
	}.
}.

//set hook to getWinchAndHook()[2].
//detachFromGround(hook).
detachAndRetract(True).
