### QuestItem.gd

extends Area2D

#npc node reference
@onready var npc = get_tree().root.get_node("%s/SpawnedNPC/NPC_2" % Global.current_scene_name)

#if the player enters the collision body, destroy item and update quest
func _on_body_entered(body):
	if body.name == "Player":
		print("Quest item obtained!")
		get_tree().queue_delete(self)
		npc.quest_complete = true
