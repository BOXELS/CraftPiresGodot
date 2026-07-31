extends ScenarioBase
## Storage: depot respects caps, deposit/withdraw round-trip through Events.

func _init() -> void:
	scenario_name = &"storage"

func setup() -> void:
	Events.reset()
	var depot := StorageDepot.new(&"player")

	var accepted: int = depot.deposit(&"wood", 150)
	assert_true(accepted == 150, "deposit accepts up to cap")
	assert_true(depot.amount(&"wood") == 150, "storage reflects deposit")

	# Over-cap deposit only takes what fits.
	var overflow: int = depot.deposit(&"wood", 100)
	assert_true(overflow == 50, "over-cap deposit clamps to remaining room (got %d)" % overflow)
	assert_true(depot.amount(&"wood") == 200, "storage capped at 200")

	# Withdraw for hauling.
	var got: int = depot.withdraw(&"wood", 25)
	assert_true(got == 25, "withdraw grants requested amount")
	assert_true(depot.amount(&"wood") == 175, "withdraw deducts from storage")

	# Withdraw more than available clamps.
	var short: int = depot.withdraw(&"wood", 9999)
	assert_true(short == 175, "withdraw clamps to available stock")
	assert_true(depot.amount(&"wood") == 0, "storage emptied after clamp")

	finish()
