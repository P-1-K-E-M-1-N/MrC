class_name WalletComponent
extends Node

## Bolt currency pouch. The vendor hook (future phase) spends from here.

signal bolts_changed(total: int)

var bolts: int = 0


func add(amount: int) -> void:
	bolts += amount
	bolts_changed.emit(bolts)


func try_spend(amount: int) -> bool:
	if amount > bolts:
		return false
	bolts -= amount
	bolts_changed.emit(bolts)
	return true
