import re

src = open(r'C:\Users\markc\Projects\telvar-test-of-fire\scenes\Level1.tscn').read()

src = src.replace('uid="uid://level1_scene"', 'uid="uid://level2_scene"')
src = src.replace('path="res://scripts/Level1.gd"', 'path="res://scripts/Level2.gd"')
src = src.replace('[node name="Level1"', '[node name="Level2"')

# load_steps: Level1 has 28, Level2 needs one more for the extra ghost sub_resource
src = src.replace('load_steps=28', 'load_steps=29')

# Add a ghost3 shape after ghost2 shape
src = src.replace(
    '[sub_resource type="RectangleShape2D" id="RectangleShape2D_ghost2"]\nsize = Vector2(20, 20)',
    '[sub_resource type="RectangleShape2D" id="RectangleShape2D_ghost2"]\nsize = Vector2(20, 20)\n\n[sub_resource type="RectangleShape2D" id="RectangleShape2D_ghost3"]\nsize = Vector2(20, 20)'
)

# Insert Undead ghost node before SpellPages
undead_block = '''[node name="Undead" type="CharacterBody2D" parent="Ghosts"]
position = Vector2(324, 348)
collision_layer = 4
collision_mask = 1
script = ExtResource("3_ghost")
ghost_type = 2

[node name="Sprite2D" type="Sprite2D" parent="Ghosts/Undead"]

[node name="CollisionShape2D" type="CollisionShape2D" parent="Ghosts/Undead"]
shape = SubResource("RectangleShape2D_ghost3")

[node name="RayCast2D" type="RayCast2D" parent="Ghosts/Undead"]
collision_mask = 1

'''

src = src.replace('[node name="SpellPages"', undead_block + '[node name="SpellPages"')

open(r'C:\Users\markc\Projects\telvar-test-of-fire\scenes\Level2.tscn', 'w').write(src)
print('Done')
