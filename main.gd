extends Control

var folder_name: String
var char_name: String
var spr_names: Array[String] = ['', '', '', '', '', '', '', '', '', '', '', '', '']
var spr_full_names: Array[String] = ['', '', '', '', '', '', '', '', '', '', '', '', '']

var sprites: Array[Array] = [[], [], [], [], [], [], [], [], [], [], [], [], []]
var sprite_counts: Array[Array]
var spr_res: Array[Array]

@onready var sprite_viewer: Node = $HBoxContainer/PreviewPanel/SpriteViewer

var active_sprites: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

@onready var layers: Array[Node] = [
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer0,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer1,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer2,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer3,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer4,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer5,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer6,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer7,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer8,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer9,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer10,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer11,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer12
]

@onready var spr_name_boxes: Array[Node] = [
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer0/VBoxContainer/SpriteName,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer1/VBoxContainer/SpriteName,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer2/VBoxContainer/SpriteName,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer3/VBoxContainer/SpriteName,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer4/VBoxContainer/SpriteName,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer5/VBoxContainer/SpriteName,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer6/VBoxContainer/SpriteName,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer7/VBoxContainer/SpriteName,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer8/VBoxContainer/SpriteName,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer9/VBoxContainer/SpriteName,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer10/VBoxContainer/SpriteName,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer11/VBoxContainer/SpriteName,
	$HBoxContainer/VBoxContainer/ScrollContainer/SpriteSelector/Layer12/VBoxContainer/SpriteName
]

var path_dir: String
var path_base: String
var exec_dir_path: String = OS.get_executable_path().get_base_dir()

func open_sprites():
	for i in range(len(sprites)):
		spr_res.append([])
		for j in range(len(sprites[i])):
			var img = Image.load_from_file(exec_dir_path + '/' + path_dir + '/' + sprites[i][j])
			var texture = ImageTexture.create_from_image(img)
			spr_res[i].append(texture)
	
	for i in range(len(spr_res)):
		if !spr_res[i].is_empty():
			sprite_viewer.get_child(i).texture = spr_res[i][0]
			layers[i].get_node('VBoxContainer/IncludeCheckbox').disabled = false
			layers[i].get_node('VBoxContainer/CodeCheckbox').disabled = false
			layers[i].get_node('VBoxContainer/BackButton').disabled = false
			layers[i].get_node('VBoxContainer/NextButton').disabled = false
			layers[i].get_node('VBoxContainer/IncludeCheckbox').button_pressed = true
			layers[i].get_node('VBoxContainer/CodeCheckbox').button_pressed = true
			layers[i].get_node('VBoxContainer/SpriteNum').text = sprite_counts[i][0]
	update_codeview()

func find_sprites():
	var dir = DirAccess.open(exec_dir_path + '/' + path_dir)
	var files: Array = Array(dir.get_files())
	
	for i in range(0, 13):
		if layers[i].get_node('VBoxContainer/CheckBox').button_pressed:
			sprites[i] = files.filter(func(file): return file == spr_full_names[i] + '.png')
		else:
			if spr_full_names[i] != '':
				sprites[i] = files.filter(func(file): return file.begins_with(spr_full_names[i]) and file.ends_with('.png'))
	
	sprite_counts = sprites.duplicate(true)
	for i in range(len(sprite_counts)):
		for j in range(len(sprite_counts[i])):
			sprite_counts[i][j] = sprite_counts[i][j].trim_prefix(spr_full_names[i]).trim_suffix('.png')
			if sprite_counts[i][j] == '':
				sprite_counts[i][j] = '+'
	
	open_sprites()

func _on_set_args_pressed():
	exec_dir_path = OS.get_executable_path().get_base_dir()
	folder_name = $HBoxContainer/VBoxContainer/HBoxContainer/FolderName.text
	char_name = $HBoxContainer/VBoxContainer/HBoxContainer/FileCharName.text
	path_dir = 'sprites/' + folder_name
	path_base = path_dir + '/' + char_name + '_'
	sprites = [[], [], [], [], [], [], [], [], [], [], [], [], []]
	for i in range(0, 13):
		spr_names[i] = spr_name_boxes[i].text
		spr_full_names[i] = char_name + '_' + spr_names[i] if spr_names[i] != '' else ''
	
	find_sprites()

func update_codeview():
	$HBoxContainer/VBoxContainer/CodeView/CodeViewLabel.text = '[code][url]'
	for i in range(13):
		print(sprites[i])
		if layers[i].get_node('VBoxContainer/CodeCheckbox').button_pressed:
			$HBoxContainer/VBoxContainer/CodeView/CodeViewLabel.text += '$ pict_[0][' + str(i) + '] = ' + path_dir + '/' + sprites[i][active_sprites[i]] + '\n'

func _on_back_button_pressed(layer):
	if active_sprites[layer] > 0:
		active_sprites[layer] -= 1
	else:
		active_sprites[layer] = len(spr_res[layer]) - 1
	sprite_viewer.get_child(layer).texture = spr_res[layer][active_sprites[layer]]
	layers[layer].get_node('VBoxContainer/SpriteNum').text = sprite_counts[layer][active_sprites[layer]]
	update_codeview()


func _on_next_button_pressed(layer):
	if active_sprites[layer] < len(spr_res[layer]) - 1:
		active_sprites[layer] += 1
	else:
		active_sprites[layer] = 0
	sprite_viewer.get_child(layer).texture = spr_res[layer][active_sprites[layer]]
	layers[layer].get_node('VBoxContainer/SpriteNum').text = sprite_counts[layer][active_sprites[layer]]
	update_codeview()


func _on_include_checkbox_toggled(button_pressed, layer):
	if !button_pressed:
		sprite_viewer.get_child(layer).hide()
		layers[layer].get_node('VBoxContainer/CodeCheckbox').button_pressed = false
		layers[layer].get_node('VBoxContainer/CodeCheckbox').disabled = true
	else:
		sprite_viewer.get_child(layer).show()
		layers[layer].get_node('VBoxContainer/CodeCheckbox').disabled = false
		layers[layer].get_node('VBoxContainer/CodeCheckbox').button_pressed = true


func _on_code_checkbox_toggled(_button_pressed, _layer):
	update_codeview()
