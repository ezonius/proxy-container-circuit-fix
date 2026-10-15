-- Proxy Container Circuit Fix
--
-- Factorio 2.1.21 changed ProxyContainerPrototype:
--   * `circuit_connector` must now be a *list* of CircuitConnectorDefinitions
--     (one entry per direction), instead of a single definition table.
--   * Added `direction_count`.
--
-- Mods written for older versions commonly assign a single definition, e.g.:
--     circuit_connector = circuit_connector_definitions["artillery-turret"]  -- create_single -> plain table
-- which now fails prototype loading with:
--     "Value must be a list in property tree at ROOT.proxy-container.<name>.circuit_connector"
--
-- Vanilla itself uses `circuit_connector_definitions.create_vector` for the
-- proxy-container (an array with one entry and no explicit direction_count),
-- so an array whose length matches direction_count (default 1) is valid.
--
-- This data-final-fixes patch runs after every other mod's data stages, but
-- before the engine validates prototypes, so we can repair all of them here:
--   * A single definition ({sprites=..., points=...}) is wrapped into a
--     one-element list (direction-agnostic, same behavior as before 2.1.21).
--   * An array without `direction_count` gets direction_count set to its
--     length, matching the "one connector per direction" model.

local patched_wrap = 0
local patched_count = 0

for _, proxy in pairs(data.raw["proxy-container"] or {}) do
	local cc = proxy.circuit_connector

	-- Single CircuitConnectorDefinition: has both `sprites` and `points`.
	-- A list of definitions does not have those keys at the top level.
	if type(cc) == "table" and cc.sprites ~= nil and cc.points ~= nil then
		proxy.circuit_connector = { cc }
		patched_wrap = patched_wrap + 1
	elseif type(cc) == "table" and #cc > 1 and proxy.direction_count == nil then
		-- Already a list (e.g. copied from a 4-direction entity like the
		-- electric-mining-drill) but no direction_count given; assume the list
		-- length is the direction count.
		proxy.direction_count = #cc
		patched_count = patched_count + 1
	end
end

if patched_wrap > 0 or patched_count > 0 then
	log("proxy-container-circuit-fix: wrapped " .. patched_wrap
		.. " single circuit_connector definition(s), set direction_count on " .. patched_count
		.. " proxy-container prototype(s).")
end
