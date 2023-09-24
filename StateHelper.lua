script_name('StateHelper')
script_authors('Kane')
script_description('Script for employees of state organizations on the Arizona Role Playing Game')
script_version('1.7')
script_properties('work-in-pause')
beta_version = 7

local text_err_and_read = {
	[1] = [[
 Не обнаружен файл SAMPFUNCS.asi в папке игры, вследствие чего
скрипту не удалось запуститься.

		Для решения проблемы:
1. Закройте игру;
2. Зайдите во вкладку "Моды" в лаунчере Аризоны.
Найдите во вкладке "Моды" установщик "Moonloader" и нажмите кнопку "Установить".
После завершения установки вновь запустите игру. Проблема исчезнет.

Если Вам это не помогло, то обращайтесь в сообщения ВКонтакте:
		vk.com/marseloy

Игра была свернута, поэтому можете продолжить играть. 
]],
	[2] = [[
		  Внимание! 
Не обнаружены некоторые важные файлы для работы скрипта.
В следствии чего, скрипт перестал работать.
	Список необнаруженных файлов:
		%s

		Для решения проблемы:
1. Закройте игру;
2. Зайдите во вкладку "Моды" в лаунчере Аризоны.
Найдите во вкладке "Моды" установщик "Moonloader" и нажмите кнопку "Установить".
После завершения установки вновь запустите игру. Проблема исчезнет.

Если Вам это не помогло, то обращайтесь в сообщения:
		vk.com/marseloy

Игра была свернута, поэтому можете продолжить играть. 
]],
	[3] = {
		'/lib/imgui.lua',
		'/lib/samp/events.lua',
		'/lib/rkeys.lua',
		'/lib/fAwesome5.lua',
		'/lib/crc32ffi.lua',
		'/lib/bitex.lua',
		'/lib/MoonImGui.dll',
		'/lib/matrix3x3.lua'
	},
	[4] = {}
}

for i,v in ipairs(text_err_and_read[3]) do
	if not doesFileExist(getWorkingDirectory()..v) then
		table.insert(text_err_and_read[4], v)
	end
end

local ffi = require 'ffi'
ffi.cdef [[
		typedef int BOOL;
		typedef unsigned long HANDLE;
		typedef HANDLE HWND;
		typedef const char* LPCSTR;
		typedef unsigned UINT;
		
        void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
        uint32_t __stdcall CoInitializeEx(void*, uint32_t);
		
		BOOL ShowWindow(HWND hWnd, int  nCmdShow);
		HWND GetActiveWindow();
		
		
		int MessageBoxA(
		  HWND   hWnd,
		  LPCSTR lpText,
		  LPCSTR lpCaption,
		  UINT   uType
		);
		
		short GetKeyState(int nVirtKey);
		bool GetKeyboardLayoutNameA(char* pwszKLID);
		int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
  ]]

--> Подключение библиотек и модулей
require 'lib.sampfuncs'
require 'lib.moonloader'
local mem = require 'memory'
local vkeys = require 'vkeys'
local encoding = require 'encoding'

if not doesFileExist(getWorkingDirectory()..'/lib/effil.lua') then
	effil_lib_NOT = true
else
	effil = require 'effil'
	effil_lib_NOT = false
end

if not doesFileExist(getWorkingDirectory()..'/lib/bass.lua') then
	bass_lib_NOT = true
else
	bass = require 'bass'
	bass.BASS_Stop()
	bass.BASS_Start()
	bass_lib_NOT = false
end

encoding.default = 'CP1251'
local u8 = encoding.UTF8
local dlstatus = require('moonloader').download_status
local shell32 = ffi.load 'Shell32'
local ole32 = ffi.load 'Ole32'
ole32.CoInitializeEx(nil, 2 + 4)

if not doesFileExist(getGameDirectory()..'/SAMPFUNCS.asi') then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, text_err_and_read[1], 'StateHelper', 0x00000030 + 0x00010000)
end
if #text_err_and_read[4] > 0 then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, text_err_and_read[2]:format(table.concat(text_err_and_read[4], '\n\t\t')), 'StateHelper', 0x00000030 + 0x00010000)
end
text_err_and_read = nil

local res, hook = pcall(require, 'lib.samp.events')
assert(res, 'Библиотека SAMP Event не найдена')
---------------------------------------------------
local res, imgui = pcall(require, 'imgui')
assert(res, 'Библиотека Imgui не найдена')
---------------------------------------------------
local res, fa = pcall(require, 'faIcons')
assert(res, 'Библиотека faIcons не найдена')
---------------------------------------------------
local res, rkeys = pcall(require, 'rkeys')
assert(res, 'Библиотека rkeys не найдена')
vkeys.key_names[vkeys.VK_RBUTTON] = 'RBut'
vkeys.key_names[vkeys.VK_XBUTTON1] = 'XBut1'
vkeys.key_names[vkeys.VK_XBUTTON2] = 'XBut2'
vkeys.key_names[vkeys.VK_NUMPAD1] = 'Num 1'
vkeys.key_names[vkeys.VK_NUMPAD2] = 'Num 2'
vkeys.key_names[vkeys.VK_NUMPAD3] = 'Num 3'
vkeys.key_names[vkeys.VK_NUMPAD4] = 'Num 4'
vkeys.key_names[vkeys.VK_NUMPAD5] = 'Num 5'
vkeys.key_names[vkeys.VK_NUMPAD6] = 'Num 6'
vkeys.key_names[vkeys.VK_NUMPAD7] = 'Num 7'
vkeys.key_names[vkeys.VK_NUMPAD8] = 'Num 8'
vkeys.key_names[vkeys.VK_NUMPAD9] = 'Num 9'
vkeys.key_names[vkeys.VK_MULTIPLY] = 'Num *'
vkeys.key_names[vkeys.VK_ADD] = 'Num +'
vkeys.key_names[vkeys.VK_SEPARATOR] = 'Separator'
vkeys.key_names[vkeys.VK_SUBTRACT] = 'Num -'
vkeys.key_names[vkeys.VK_DECIMAL] = 'Num .Del'
vkeys.key_names[vkeys.VK_DIVIDE] = 'Num /'
vkeys.key_names[vkeys.VK_LEFT] = 'Ar.Left'
vkeys.key_names[vkeys.VK_UP] = 'Ar.Up'
vkeys.key_names[vkeys.VK_RIGHT] = 'Ar.Right'
vkeys.key_names[vkeys.VK_DOWN] = 'Ar.Down'

--> Скачивание изображений
IMG_Record = {}
function download_image()
	if not doesDirectoryExist(getWorkingDirectory()..'/StateHelper/Изображения/') then
		print('{F54A4A}Ошибка. Отсутствует папка для изображений. {82E28C}Создание папки для изображений...')
		createDirectory(getWorkingDirectory()..'/StateHelper/Изображения/')
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/Изображения/No label.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/Zud78GE.png', getWorkingDirectory()..'/StateHelper/Изображения/No label.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				IMG_No_Label = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/No label.png')
				local texture_im = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/No label.png')
				IMG_Record = {texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im}
			end
		end)
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/Изображения/Background.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/fuPlVzV.png', getWorkingDirectory()..'/StateHelper/Изображения/Background.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				IMG_Background = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Background.png')
			end
		end)
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/Изображения/Background Black.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/yi98wxe.png', getWorkingDirectory()..'/StateHelper/Изображения/Background Black.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				IMG_Background_Black = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Background Black.png')
			end
		end)
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/Изображения/Background White.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/CHJ54FR.png', getWorkingDirectory()..'/StateHelper/Изображения/Background White.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				IMG_Background_White = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Background White.png')
			end
		end)
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/Изображения/Premium.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/11nmU1n.png', getWorkingDirectory()..'/StateHelper/Изображения/Premium.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				IMG_Premium = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Premium.png')
			end
		end)
	end
	
	local function download_record_label(url_label_record, name_label, i_rec)
		if not doesFileExist(getWorkingDirectory()..'/StateHelper/Изображения/'..name_label..'.png') then
			download_id = downloadUrlToFile(url_label_record, getWorkingDirectory()..'/StateHelper/Изображения/'..name_label..'.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
					IMG_Record[i_rec] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/'..name_label..'.png')
				end
			end)
		end
	end
	
	download_record_label('https://i.imgur.com/F6hxtdC.png', 'Record Dance Label', 1)
	download_record_label('https://imgur.com/lsYixKr.png', 'Record Megamix Label', 2)
	download_record_label('https://imgur.com/lEpOpLy.png', 'Record Party Label', 3)
	download_record_label('https://imgur.com/UWHK1nN.png', 'Record Phonk Label', 4)
	download_record_label('https://imgur.com/GkovIZT.png', 'Record GopFM Label', 5)
	download_record_label('https://imgur.com/ZftaAuK.png', 'Record Ruki Vverh Label', 6)
	download_record_label('https://imgur.com/Q8Jed4R.png', 'Record Dupstep Label', 7)
	download_record_label('https://imgur.com/OeGdMu8.png', 'Record Bighits Label', 8)
	download_record_label('https://imgur.com/xuOZVCU.png', 'Record Organic Label', 9)
	download_record_label('https://imgur.com/SnA1FR8.png', 'Record Russianhits Label', 10)
end
download_image()

--> Скачивание шрифтов
installation_success_font = {false, false}
secc_load_font = false
function download_font()
	local link_meduim_font = 'https://vk.com/s/v1/doc/M6wrSqXBqVNhL_tTya03mfV4Vu45JxpJVf2YgfUWuHx_LT5vaxY'
	local link_bold_font = 'https://vk.com/s/v1/doc/OK2diNG7yhEXKf6Re7CA21PiWW6foksR3naH9nuQqSPmCTm-sl0'
	if not doesDirectoryExist(getWorkingDirectory()..'/StateHelper/Fonts/') then
		print('{F54A4A}Ошибка. Отсутствует папка для шрифтов. {82E28C}Создание папки для шрифтов...')
		createDirectory(getWorkingDirectory()..'/StateHelper/Fonts/')
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf') or not doesFileExist(getWorkingDirectory()..'/StateHelper/Fonts/SF800.ttf') then
		download_id = downloadUrlToFile(link_meduim_font, getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				installation_success_font[1] = true
				secc_load_font = true
			end
		end)
		download_id = downloadUrlToFile(link_bold_font, getWorkingDirectory()..'/StateHelper/Fonts/SF800.ttf', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				installation_success_font[2] = true
				secc_load_font = true
			end
		end)
	else
		installation_success_font = {true, true}
		secc_load_font = true
	end
end
download_font()

--> Файловая система
dirml = getWorkingDirectory()
dirGame = getGameDirectory()
scr = thisScript()
font = renderCreateFont('Trebuchet MS', 14, 5)
fontPD = renderCreateFont('Trebuchet MS', 12, 5)
sx, sy = getScreenResolution()

--> Окна imgui и их зависимости
local win = {
	main = imgui.ImBool(false), --> Главное
	spur_big = imgui.ImBool(false), --> Большое окно шпоры
	icon = imgui.ImBool(false), --> Иконки
	action_choice = imgui.ImBool(false), --> Быстрое взаимодействие
	reminder = imgui.ImBool(false), --> Напоминания
	notice = imgui.ImBool(false), --> Уведомления системы
	music = imgui.ImBool(false) --> Музыкальный плеер
}
local select_main_menu = {false, false, false, false, false, false, false, false, false, false, false} --> Для главного меню
local select_basic = {false, false, false, false, false, false, false, false, false, false} --> Для меню основное
local notice = {} --> Значения уведомлений (текст, заголовок, тип - предупреждение/уведомление/инфо)

--> Обновление и её зависимости
upd = {}
url_upd = 'https://raw.githubusercontent.com/KaneScripter/StateHelper/main/StateHelper.lua'
upd_status = 0
scr_version = scr.version:gsub('%D','')
scr_version = tonumber(scr_version)

--> Несохраняемая информация
local pers = {
	frac = {org = 'Больница ЛС', title = '', rank = 1}
}
org_all_done = {u8'Больница ЛС', u8'Больница ЛВ', u8'Больница СФ', u8'Больница Джефферсон', u8'Центральный Банк', u8'Центр Лицензирования'}
num_of_the_selected_org = 1
my = {id = 0, nick = 'Nick_Name'}
off_butoon_end = false
error_spawn = false
wind_act_wait = false
edit_key = false
right_mb = false
current_key = {'', {}}
stop_key_move = false
num_give_lic = -1
flies_nick = 'Nick_Name'
sel_big_spur = 1
text_spur = ''
spur_text_size = 2
inp_text_dep = ''
dep_history = {}
id_sobes = ''
sobes_menu = false
pl_sob = {id = 0, nm = 'Nick_Name'}
inp_text_sob = ''
sob_history = {}
sob_info = {
	level = -1,
	legal = -1,
	work = -1,
	narko = -1,
	hp = -1,
	bl = -1
}
scroll_sob = 0
reminder_buf = {}
reminder_edit = false
rem_fl_h = imgui.ImFloat(1.0)
rem_fl_m = imgui.ImFloat(1.0)
remove_reminder = 0
rem_text = ''
scene_active = false
col_sc = {}
script_cursor_sc = false
speed = 0.25
preview_sc = false
edit_sc = false
scene_edit_i = false
price_lic = 0
pos_Y_cmd = 35
active_child_cmd = false
POS_Y_CMD_F = -50
bool_rubber_stick = false
targ_id = 0
lec_buf = {}
select_lec = 0
lec_err_nm = false
lec_err_fact = false
sdvig = 0
sdgiv_bool = false
sdvig_num = 0
session_clean = imgui.ImInt(0)
session_afk = imgui.ImInt(0)
session_all = imgui.ImInt(0)
select_stat = 0
num_give_lic_term = 0
anim_menu_draw = {177, false}
lastTime = os.clock()
anim_menu_cmd = {130, os.clock(), 0.00}
close_stats = true
new_pos_win_size = {0, 0}
size_win = false
new_pos = 0
start_pos = 0
num_give_bank = -1
anim_menu_shpora = {0, os.clock(), false, 0}
update_box = false
time_os_shp = os.clock()
audio_vizual = 0
start_time_mus = os.time()
current_time_mus = start_time_mus
local deltaTime = 0
target_audio_vizual = 0
level_potok = 0
frequency = 0

--> Главные настройки
setting = {
	int = {first_start = true, script = 'Helper', theme = 'White'},
	frac = {org = u8'Больница ЛС', title = u8'Бывалый', rank = 10},
	nick = '',
	teg = '',
	act_time = '',
	act_r = '',
	sex = u8'Мужской',
	price = {
		lec = '5000',
		mede = {'20000', '40000', '60000', '80000'},
		upmede = {'40000', '60000', '80000', '100000'},
		rec = '20000',
		narko = '100000',
		tatu = '120000',
		ant = '20000'
	},
	price_cl = {
		auto = '5000',
		moto = '10000',
		fish = '30000',
		swim = '30000',
		gun = '50000',
		hunt = '100000',
		exc = '200000',
		taxi = '250000',
		meh = '450000'
	},
	chat_pl = false,
	chat_help = false,
	chat_smi = false,
	time_hud = false,
	auto_lec = false,
	accent = {func = false, text = '', r = false, f = false, d = false, s = false},
	members = {
		func = false, 
		dialog = false, 
		invers = false, 
		form = false, 
		rank = false, 
		id = false, 
		afk = false, 
		warn = false, 
		size = 12, 
		flag = 5, 
		dist = 21, 
		vis = 180, 
		color = {title = 0xFFFF8585, default = 0xFFFFFFFF, work = 0xFFFF8C00},
		pos = {x = sx - 30, y = sy / 3},
	},
	notice = {car = false, dep = false},
	dep = {my_tag = '', my_tag_en = ''},
	depart = {format = u8'[ЛСМЦ] - [ЛСПД]:', my_tag = '', else_tag = '', volna = ''},
	speed_door = false,
	dep_off = false,
	anim_main = false,
	cmd = {
		{'z', u8'Приветствие', {}, '1'},
		{'exp', u8'Выгнать из помещения', {}, '3'},
		{'za', u8'Отправит фразу "Пройдёмте за мной"', {}, '1'},
		{'show', u8'Показать игроку свои документы', {}, '1'},
		{'cam', u8'Начать или прекратить видеофиксацию', {}, '1'},
		{'mb', u8'Сокращённая команда /members', {}, '1'},
		{'+mute', u8'Выдать бан чата организации сотруднику', {}, '8'},
		{'-mute', u8'Снять бан чата организации сотруднику', {}, '8'},
		{'+warn', u8'Выдать сотруднику выговор', {}, '8'},
		{'-warn', u8'Снять выговор сотруднику', {}, '8'},
		{'inv', u8'Принять игрока в организацию', {}, '9'},
		{'uninv', u8'Уволить сотрудника', {}, '9'},
		{'rank', u8'Установить сотруднику ранг', {}, '9'},
	},
	show_dialog_auto = true,
	fast_acc = {
		func = true,
		sl = {}
	},
	shpora = {},
	sob = {
		level = 3,
		legal = 35,
		narko = 5,
		qq = {{
			nm = u8'Попросить документы', 
			q = {
			u8'Для трудоустройства необходимо предоставить следующий пакет документов:',
			u8'Паспорт, медицинскую карту и лицензии.',
			u8'/n Отыгрывая, с использованием команд /me, /do, /todo'}},
			{
			nm = u8'Рассказать о себе',
			q = {
			u8'Хорошо, расскажите немного о себе.'}},
			{
			nm = u8'Почему Вы выбрали нас',
			q = {
			u8'Хорошо, скажите, почему Вы выбрали именно нас?'}},
			{
			nm = u8'Вас убивали?',
			q = {
			u8'Хорошо, давайте проверим Вашу психику.',
			u8'Скажите, Вас когда-нибудь убивали?'}},
			{
			nm = u8'Где Вы находитесь?',
			q = {
			u8'Хорошо, скажите, где Вы сейчас находитесь?'}},
			{
			nm = u8'Название купюр',
			q = {
			u8'Отлично, скажите, как называются купюры, которыми Вы расплачиваетесь?'}},
			{
			nm = u8'Рация дискорд',
			q = {
			u8'Хорошо, скажите, имеется ли у Вас спец. рация Discord?'}}}
		},
	reminder = {},
	stat = {
		hosp = {
			payday = {0, 0, 0, 0, 0, 0, 0},
			lec = {0, 0, 0, 0, 0, 0, 0},
			medcard = {0, 0, 0, 0, 0, 0, 0},
			apt = {0, 0, 0, 0, 0, 0, 0},
			ant = {0, 0, 0, 0, 0, 0, 0},
			rec = {0, 0, 0, 0, 0, 0, 0},
			medcam = {0, 0, 0, 0, 0, 0, 0},
			cure = {0, 0, 0, 0, 0, 0, 0},
			tatu = {0, 0, 0, 0, 0, 0, 0},
			total_week = 0,
			total_all = 0,
			date_num = {0, 0},
			date_today = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
			date_last = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
			date_week = {os.date('%d.%m.%Y'), '', '', '', '', '', ''}
		},
		school = {
			payday = {0, 0, 0, 0, 0, 0, 0},
			auto = {0, 0, 0, 0, 0, 0, 0},
			moto = {0, 0, 0, 0, 0, 0, 0},
			fish = {0, 0, 0, 0, 0, 0, 0},
			swim = {0, 0, 0, 0, 0, 0, 0},
			gun = {0, 0, 0, 0, 0, 0, 0},
			hun = {0, 0, 0, 0, 0, 0, 0},
			exc = {0, 0, 0, 0, 0, 0, 0},
			taxi = {0, 0, 0, 0, 0, 0, 0},
			meh = {0, 0, 0, 0, 0, 0, 0},
			total_week = 0,
			total_all = 0,
			date_num = {0, 0},
			date_today = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
			date_last = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
			date_week = {os.date('%d.%m.%Y'), '', '', '', '', '', ''}
		},
	},
	mus = {
		rep = false,
		win = true,
		volume = 1
	},
	rp_zone = false,
	auto_update = false,
	ts = true,
	rubber_stick = true,
	lec = {},
	color_accent_num = 1,
	col_acc_non = {0.26, 0.45, 0.94},
	col_acc_act = {0.26, 0.35, 0.94},
	online_stat = {
		clean = {0, 0, 0, 0, 0, 0, 0},
		afk = {0, 0, 0, 0, 0, 0, 0},
		all = {0, 0, 0, 0, 0, 0, 0},
		total_week = 0,
		total_all = 0,
		date_num = {0, 0},
		date_today = {os.date('%d') + 0, os.date('%m') + 0, os.date('%Y') + 0},
		date_last = {os.date('%d') + 0, os.date('%m') + 0, os.date('%Y') + 0},
		date_week = {os.date('%d.%m.%Y'), '', '', '', '', '', ''} --> Дата за неделю в формате [день, месяц, год]
	},
	priceosm = '200000',
	start_pos = 0,
	new_pos = 0,
	new_mus_fix = true,
}

local buf_setting = {
	theme = {imgui.ImBool(true), imgui.ImBool(false)}
}
script_tag = '[SH] '
color_tag = 0xFF5345

--> Для РП зоны
scene = {bq = {}}
scene_buf = {}
select_scene = 0

--> Для команд
local select_cmd = 0
cmd = {
	nm = '',
	desc = u8'',
	delay = 2000,
	key = {},
	arg = {},
	var = {},
	act = {},
	num_d = 1,
	tr_fl = {0, 0, 0},
	add_f = {false, 1},
	not_send_chat = false,
	rank = '1'
}
cmds = {}

--> Для шпор
local select_shpora = 0
shpora = {
	nm = '',
	text = ''
}

--> Работа с датами
week = {'Воскресенье', 'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота'}
month = {'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня', 'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'}

--> Для обновления
new_version = {beta = beta_version, version = scr_version}
type_version = {rel = false, beta = false}
upd_info = nil

--> Обработка шрифтов
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local the_path_to_the_file_font = 'moonloader/lib/fontawesome-webfont.ttf'
if not doesFileExist(getWorkingDirectory()..'/lib/fontawesome-webfont.ttf') then
	the_path_to_the_file_font = 'moonloader/resource/fonts/fontawesome-webfont.ttf'
end

local font = {}
local bold_font = {}
local fa_font = {}

function update_render_font()
	function imgui.BeforeDrawFrame()
		if fa_font[1] == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = true

			fa_font[1] = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 18.0, font_config, fa_glyph_ranges)
		end
		if fa_font[2] == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = false

			fa_font[2] = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 10.0, font_config, fa_glyph_ranges)
		end
		if fa_font[3] == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = false

			fa_font[3] = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 8.0, font_config, fa_glyph_ranges)
		end
		if fa_font[4] == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = false

			fa_font[4] = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 15.0, font_config, fa_glyph_ranges)
		end
		if fa_font[5] == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = false

			fa_font[5] = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 25.0, font_config, fa_glyph_ranges)
		end
		if fa_font[6] == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = false

			fa_font[6] = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 35.0, font_config, fa_glyph_ranges)
		end
		if font[1] == nil then
			font[1] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf', 15.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			font[2] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf', 60.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			font[3] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf', 13.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			font[4] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf',  20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			font[5] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf',  40.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			font[6] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf',  10.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			font[7] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf',  18.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
		end
		if bold_font[1] == nil then
			bold_font[1] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/StateHelper/Fonts/SF800.ttf', 22.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			bold_font[2] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/StateHelper/Fonts/SF800.ttf', 60.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			bold_font[3] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/StateHelper/Fonts/SF800.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			bold_font[4] = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/StateHelper/Fonts/SF800.ttf', 40.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
		end
	end
end

--> Проверка существование папки и её создание
if not doesDirectoryExist(dirml..'/StateHelper/') then
	print('{F54A4A}Ошибка. Отсутствует папка State Helper. {82E28C}Создание папки для скрипта...')
	createDirectory(dirml..'/StateHelper/')
end

function check_existence(name_folder, description_folder) --> Создание папки, если её нет
	local status_folder = true
	if not doesDirectoryExist(dirml..'/StateHelper/'..name_folder..'/') then
		print('{F54A4A}Ошибка. Отсутствует папка '..description_folder..'. {82E28C}Создание папки '..description_folder..'...')
		createDirectory(dirml..'/StateHelper/'..name_folder..'/')
		status_folder = false
	end
	
	return status_folder
end

function apply_settings(name_file, description_file, array_arg) --> Загрузка настроек или создание файла настроек
	if doesFileExist(dirml..'/StateHelper/'..name_file) then
		print('{82E28C}Чтение файла '..description_file..'...')
		local f = io.open(dirml..'/StateHelper/'..name_file)
		local set = f:read('*a')
		f:close()
		local res, sets = pcall(decodeJson, set)
		if res and type(sets) == 'table' then 
			for nm_array_orig, value_orig in pairs(array_arg) do
				local success_check = false
				for nm_array_set, value_set in pairs(sets) do
					if nm_array_orig == nm_array_set then
						success_check = true
						array_arg[nm_array_orig] = value_set
					end
				end
				if not success_check then
					array_arg[nm_array_orig] = value_orig
				end
			end
			local f = io.open(dirml..'/StateHelper/'..name_file, 'w')
			f:write(encodeJson(array_arg))
			f:flush()
			f:close()
		else
			os.remove(dirml..'/StateHelper/'..name_file)
			print('{F54A4A}Ошибка. Файл '..description_file..' повреждён. {82E28C}Создание нового файла...')
			local f = io.open(dirml..'/StateHelper/'..name_file, 'w')
			f:write(encodeJson(array_arg))
			f:flush()
			f:close()
		end
	else
		print('{F54A4A}Ошибка. Файл '..description_file..' не найден. {82E28C}Создание нового файла...')
		if not doesFileExist(dirml..'/StateHelper/'..name_file) then
			local f = io.open(dirml..'/StateHelper/'..name_file, 'w')
			f:write(encodeJson(array_arg))
			f:flush()
			f:close()
		end
	end
	
	return array_arg
end

--> Музыка
select_music = 1
stream_music = nil
site_link = 'rur.hitmotop.com'
record = {
	[1] = 'http://radio-srv1.11one.ru/record192k.mp3',
	[2] = 'http://radiorecord.hostingradio.ru/mix96.aacp',
	[3] = 'http://radiorecord.hostingradio.ru/party96.aacp',
	[4] = 'http://radiorecord.hostingradio.ru/phonk96.aacp',
	[5] = 'http://radiorecord.hostingradio.ru/gop96.aacp',
	[6] = 'http://radiorecord.hostingradio.ru/rv96.aacp',
	[7] = 'http://radiorecord.hostingradio.ru/dub96.aacp',
	[8] = 'http://radiorecord.hostingradio.ru/bighits96.aacp',
	[9] = 'http://radiorecord.hostingradio.ru/organic96.aacp',
	[10] = 'http://radiorecord.hostingradio.ru/russianhits96.aacp'
}
record_name = {'Dance', 'Megamix', 'Party 24/7', 'Phonk', 'Гоп FM', 'Руки Вверх', 'Dubstep', 'Big Hits', 'Organic', 'Russian Hits'}
volume_buf = imgui.ImFloat(1.0)
status_potok = 0
text_find_track = ''
selectis = 0
qua_page = 1
current_page = 1
timetr = {0, 0}
track_time_hc = 0
status_track_pl = 'STOP'
url_track_pack = url_track
status_image = -1
menu_play_track = {false, false, false}
sectime_track = imgui.ImFloat(1.0)
artist = ''
name_tr = ''
select_record = 0
sel_link = ''
tracks = {
	link = {},
	artist = {},
	name = {},
	time = {},
	image = {}
}
save_tracks = {
	link = {},
	artist = {},
	name = {},
	time = {},
	image = {}
}

function get_status_potok_song() --> Получить статус потока
	local status_potok
	if stream_music ~= nil then
		status_potok = bass.BASS_ChannelIsActive(stream_music)
		status_potok = tonumber(status_potok)
	else
		status_potok = 0
	end
	return status_potok
	--[[
	[0] - Ничего не воспроизводится
	[1] - Играет
	[2] - Блок
	[3] - Пауза
	--]]
end

function rewind_song(time_position) --> Перемотка трека на указанную позицию (позиция трека в секундах)
	if status_track_pl ~= 'STOP' and not menu_play_track[3] and get_status_potok_song() ~= 0 then
		local length = bass.BASS_ChannelGetLength(stream_music, BASS_POS_BYTE)
		length = tostring(length)
		length = length:gsub('(%D+)', '')
		length = tonumber(length)
		local poslt = ((length/track_time_hc) * time_position) - 100
		bass.BASS_ChannelSetPosition(stream_music, poslt, BASS_POS_BYTE)
		local time_song = 0
		time_song = time_song_position(track_time_hc)
		time_song = round(time_song, 1)
		timetr[1] = time_song % 60
		timetr[2] = math.floor(time_song / 60)
	end
end

function time_song_position(song_length) --> Получить позицию трека в секундах
	song_length = tonumber(song_length)
	local posByte = bass.BASS_ChannelGetPosition(stream_music, BASS_POS_BYTE)
	posByte = tostring(posByte)
	posByte = posByte:gsub('(%D+)', '')
	posByte = tonumber(posByte)
	local length = bass.BASS_ChannelGetLength(stream_music, BASS_POS_BYTE)
	length = tostring(length)
	length = length:gsub('(%D+)', '')
	length = tonumber(length)
	local postrack = posByte / (length / song_length)
	
	return postrack
end

function find_track_link(search_text, page) --> Поиск песни в интернете
	tracks = {
		link = {},
		artist = {},
		name = {},
		time = {},
		image = {}
	}
	local page_ssl = ''
	local all_page_num = 1
	local page_table = {'1'}
	current_page = page
	local function remove_duplicates(array)
		local seen = {}
		local result = {}

		for _, value in ipairs(array) do
			if not seen[value] then
				table.insert(result, value)
				seen[value] = true
			end
		end

		return result
	end
	if page == 2 then
		page_ssl = '/start/48'
	elseif page == 3 then
		page_ssl = '/start/96'
	elseif page == 4 then
		page_ssl = '/start/144'
	end
	
	asyncHttpRequest('GET', 'https://'..site_link..'/search'..page_ssl..'?q='..urlencode(u8(u8:decode(search_text))), nil,
		function(response)
			if page == 1 then
				for link in string.gmatch(u8:decode(response.text), '/search/start/48') do
					table.insert(page_table, '48')
				end
				for link in string.gmatch(u8:decode(response.text), '/search/start/96') do
					table.insert(page_table, '96')
				end
				for link in string.gmatch(u8:decode(response.text), '/search/start/144') do
					table.insert(page_table, '144')
				end
				local new_arr = remove_duplicates(page_table)
				qua_page = #new_arr
			end
			for link in string.gmatch(u8:decode(response.text), 'По вашему запросу ничего не найдено') do
				tracks.link[1] = 'Ошибка404'
				tracks.artist[1] = 'Ошибка404'
			end
			for link in string.gmatch(u8:decode(response.text), 'href="(.-)" class=') do
				if link:find('https://'..site_link..'/get/music/') then
					track = link:match('(.+).mp3')
					tracks.link[#tracks.link + 1] = track..'.mp3'
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_title"%>(.-)%</div') do
				if link:find('(.+)') then
					nametrack = link:match('(.+)')
					nametrack = nametrack:gsub('^%s+', '')
					tracks.name[#tracks.name + 1] = nametrack:gsub('%s+$', '')
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_desc"%>(.-)%</div') do
				if link:find('(.+)') then
					tracks.artist[#tracks.artist + 1] = link:match('(.+)')
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_fulltime"%>(.-)%</div') do
				if link:find('(.+)') then
					tracks.time[#tracks.time + 1] = link:match('(.+)')
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_img" style="background%-image: url%(\'(.-)\'%)%;"%>%</div%>') do
				if link:find('(.+)') then
					tracks.image[#tracks.image + 1] = link:match('(.+)')
				end
			end
		end,
		function(err)
		print(err)
	end)
end

function get_track_length() --> Получить длину трека в секундах
	local len_song = 0
	if menu_play_track[1] or menu_play_track[2] then
		local min_tr = 0
		local sec_tr = 0
		if menu_play_track[1] then
			min_tr = tracks.time[selectis]:gsub(':(.+)', '')
			sec_tr = tracks.time[selectis]:gsub('(.+):', '')
		else
			min_tr = save_tracks.time[selectis]:gsub(':(.+)', '')
			sec_tr = save_tracks.time[selectis]:gsub('(.+):', '')
		end
		min_tr = tonumber(min_tr)
		sec_tr = tonumber(sec_tr)
		len_song = (min_tr * 60) + sec_tr
	end
	
	return len_song
end

function play_song(url_track, loop_track) --> Включить песню
	timetr = {0, 0}
	track_time_hc = 0
	status_track_pl = 'PLAY'
	url_track_pack = url_track
	if menu_play_track[1] then
		local tri = tracks.time[selectis]:gsub(':(.+)$', '')
		local tri2 = tracks.time[selectis]:gsub('^(.+):', '')
		timetri = 400/((tonumber(tri)*60)+tonumber(tri2))
		artist = tracks.artist[selectis]
		name_tr = tracks.name[selectis]
		sel_link = url_track
	elseif menu_play_track[2] then
		local tri = save_tracks.time[selectis]:gsub(':(.+)$', '')
		local tri2 = save_tracks.time[selectis]:gsub('^(.+):', '')
		timetri = 400/((tonumber(tri)*60)+tonumber(tri2))
		artist = save_tracks.artist[selectis]
		name_tr = save_tracks.name[selectis]
	end
	track_time_hc = get_track_length()
	if get_status_potok_song() ~= 0 then
		bass.BASS_ChannelStop(stream_music)
	end
	stream_music = bass.BASS_StreamCreateURL(url_track, 0, BASS_STREAM_AUTOFREE, nil, nil)
	if loop_track ~= true then
		bass.BASS_ChannelPlay(stream_music, false)
	elseif loop_track == true then
		bass.BASS_ChannelPlay(stream_music, BASS_SAMPLE_LOOP)
	end
	bass.BASS_ChannelSetAttribute(stream_music, BASS_ATTRIB_VOL, volume_buf.v)
	if menu_play_track[1] then
		if not tracks.image[selectis]:find('no%-cover%-150') then
			download_id = downloadUrlToFile(tracks.image[selectis], getWorkingDirectory()..'/StateHelper/Изображения/Label.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					status_image = selectis
					IMG_label = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Label.png')
				end
			end)
		else
			status_image = selectis
			IMG_label = IMG_No_Label
		end
	elseif menu_play_track[2] then
		if not save_tracks.image[selectis]:find('no%-cover%-150') then
			download_id = downloadUrlToFile(save_tracks.image[selectis], getWorkingDirectory()..'/StateHelper/Изображения/Label.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					status_image = selectis
					IMG_label = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Label.png')
				end
			end)
		else
			status_image = selectis
			IMG_label = IMG_No_Label
		end
	end
end

function action_song(action_music) --> Остановить/Пауза/Продолжить
	if stream_music ~= nil and get_status_potok_song() ~= 0 then
		if action_music == 'PLAY' then
			status_track_pl = 'PLAY'
			bass.BASS_ChannelPlay(stream_music, false)
		elseif action_music == 'PAUSE' then
			status_track_pl = 'PAUSE'
			bass.BASS_ChannelPause(stream_music)
		elseif action_music == 'STOP' then
			selectis = 0
			select_record = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
			bass.BASS_ChannelStop(stream_music)
		end
	end
end

function volume_song(volume_music) --> Установить громкость песни
	if stream_music ~= nil and get_status_potok_song() ~= 0 then
		bass.BASS_ChannelSetAttribute(stream_music, BASS_ATTRIB_VOL, volume_music)
	end
end

function back_track()
	if menu_play_track[1] then
		if selectis > 1 and tracks.link[selectis] == url_track_pack then
			selectis = selectis - 1
			play_song(tracks.link[selectis], false)
		elseif selectis == 1 or tracks.link[selectis] ~= url_track_pack then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	elseif menu_play_track[2] then
		if selectis > 1 and save_tracks.link[selectis - 1] ~= nil then
			selectis = selectis - 1
			play_song(save_tracks.link[selectis], false)
		elseif selectis == 1 or save_tracks.link[selectis - 1] == nil then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	end
end

function next_track()
	if menu_play_track[1] then
		if selectis ~= 0 and selectis < #tracks.link and tracks.link[selectis] == url_track_pack then
			selectis = selectis + 1
			play_song(tracks.link[selectis], false)
		elseif (selectis ~= 0 and selectis == #tracks.link) or tracks.link[selectis] ~= url_track_pack then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	elseif menu_play_track[2] then
		if selectis ~= 0 and selectis < #save_tracks.link and save_tracks.link[selectis + 1] ~= nil then
			selectis = selectis + 1
			play_song(save_tracks.link[selectis], false)
		elseif (selectis ~= 0 and selectis == #save_tracks.link) or save_tracks.link[selectis + 1] == nil then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	end
end

function stalecatin()
	if get_status_potok_song() == 3 and status_track_pl == 'PLAY' then
		action_song('PLAY')
	elseif get_status_potok_song() == 0 and status_track_pl == 'PLAY' then
		if setting.mus.rep then
			play_song(url_track_pack, false)
		else
			next_track()
		end
	end
end

function main()
	repeat wait(300) until isSampAvailable()
	local base = getModuleHandle('samp.dll')
	local sampVer = mem.tohex(base + 0xBABE, 10, true)
	if sampVer == 'E86D9A0A0083C41C85C0' then
		sampIsLocalPlayerSpawned = function()
			local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			return sampGetGamestate() == 3 and res and sampGetPlayerAnimationId(id) ~= 0
		end
	end
	if script.this.filename:find('%.luac') then
		os.rename(getWorkingDirectory()..'\\StateHelper.luac', getWorkingDirectory()..'\\StateHelper.lua') 
	end
	thread = lua_thread.create(function() return end)
	pos_new_memb = lua_thread.create(function() return end)
	
	--> Создание файлов и установка значений
	check_existence('Для обновления', 'для обновлений')
	check_existence('Отыгровки', 'для отыгровок')
	check_existence('Шпаргалки', 'для шпаргалок')
	
	setting = apply_settings('Настройки.json', 'настроек', setting)
	save_tracks = apply_settings('Треки.json', 'треков', save_tracks)
	scene = apply_settings('Сцены.json', 'сцен', scene)
	
	repeat wait(100) until sampIsLocalPlayerSpawned()
	local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	my = {id = myid, nick = sampGetPlayerNickname(myid)}
	sampAddChatMessage(string.format(script_tag..'{FFFFFF}%s, для активации главного меню, отправьте в чат {a8a8a8}/sh', sampGetPlayerNickname(my.id):gsub('_',' ')), color_tag)
	
	if doesFileExist(dirml..'/MedicalHelper.lua') then
		os.remove(dirml..'/MedicalHelper.lua')
	end
	
	if setting.int.first_start then
		first_start_anim = {
			text = {false, false, false, false, false, false},
			done = {false, false, false, false, false, false},
			vis = {0, 0},
			pos = {200, 200}
		}
	end
	if IMG_Premium == nil then
		IMG_Premium = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Premium.png')
	end
	fontes = renderCreateFont('Trebuchet MS', setting.members.size, setting.members.flag)
	if setting.speed_door then
		rkeys.registerHotKey({72}, 1, false, function() on_hot_key({72}) end)
	end
	if #setting.cmd ~= 0 then
		for i = 1, #setting.cmd do
			if #setting.cmd[i][3] ~= 0 then
				rkeys.registerHotKey(setting.cmd[i][3], 3, true, function() on_hot_key(setting.cmd[i][3]) end)
			end
		end
	end
	if setting.dep_off then
		sampRegisterChatCommand('d', function()
			sampAddChatMessage(script_tag..'{FFFFFF}Вы отключили команду /d в настройках.', color_tag)
		end)
	end
	if setting.accent.d and not setting.dep_off then
		sampRegisterChatCommand('d', function(text_accents_d) 
			if text_accents_d ~= '' and setting.accent.func and setting.accent.d and setting.accent.text ~= '' then
				sampSendChat('/d ['..u8:decode(setting.accent.text)..' акцент]: '..text_accents_d)
			else
				sampSendChat('/d '..text_accents_d)
			end 
		end)
	end
	
	if setting.ts then
		sampRegisterChatCommand('ts', print_scr_time)
	end
	
	if setting.int.theme ~= 'White' then
		buf_setting.theme[1].v = false
		buf_setting.theme[2].v = true
	end
	col = {
		title = convert_color(setting.members.color.title),
		default = convert_color(setting.members.color.default),
		work = convert_color(setting.members.color.work)
	}
	
	if setting.frac.org:find(u8'Больница') then
		setting.stat.hosp.date_today = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))}
		if setting.stat.hosp.date_today[1] ~= setting.stat.hosp.date_last[1] or setting.stat.hosp.date_today[2] ~= setting.stat.hosp.date_last[2]
		or setting.stat.hosp.date_today[3] ~= setting.stat.hosp.date_last[3] then
			setting.stat.hosp.date_num[1] = setting.stat.hosp.date_num[1] + 1
		end
		if setting.stat.hosp.date_num[1] > setting.stat.hosp.date_num[2] then
			setting.stat.hosp.date_last = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))}
			setting.stat.hosp.date_num[2] = setting.stat.hosp.date_num[1]
			for i = 6, 1, -1 do
				setting.stat.hosp.date_week[i + 1] = setting.stat.hosp.date_week[i]
				setting.stat.hosp.payday[i + 1] = setting.stat.hosp.payday[i]
				setting.stat.hosp.lec[i + 1] = setting.stat.hosp.lec[i]
				setting.stat.hosp.medcard[i + 1] = setting.stat.hosp.medcard[i]
				setting.stat.hosp.apt[i + 1] = setting.stat.hosp.apt[i]
				setting.stat.hosp.ant[i + 1] = setting.stat.hosp.ant[i]
				setting.stat.hosp.rec[i + 1] = setting.stat.hosp.rec[i]
				setting.stat.hosp.medcam[i + 1] = setting.stat.hosp.medcam[i]
				setting.stat.hosp.tatu[i + 1] = setting.stat.hosp.tatu[i]
			end
			setting.stat.hosp.date_week[1] = os.date('%d.%m.%Y')
			setting.stat.hosp.payday[1] = 0
			setting.stat.hosp.lec[1] = 0
			setting.stat.hosp.medcard[1] = 0
			setting.stat.hosp.apt[1] = 0
			setting.stat.hosp.ant[1] = 0
			setting.stat.hosp.rec[1] = 0
			setting.stat.hosp.medcam[1] = 0
			setting.stat.hosp.tatu[1] = 0
		end
		save('setting')
	elseif setting.frac.org:find(u8'Центр Лицензирования') then
		setting.stat.school.date_today = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))}
		if setting.stat.school.date_today[1] ~= setting.stat.school.date_last[1] or setting.stat.school.date_today[2] ~= setting.stat.school.date_last[2]
		or setting.stat.school.date_today[3] ~= setting.stat.school.date_last[3] then
			setting.stat.school.date_num[1] = setting.stat.school.date_num[1] + 1
		end
		if setting.stat.school.date_num[1] > setting.stat.school.date_num[2] then
			setting.stat.school.date_last = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))}
			setting.stat.school.date_num[2] = setting.stat.school.date_num[1]
			for i = 6, 1, -1 do
				setting.stat.school.date_week[i + 1] = setting.stat.school.date_week[i]
				setting.stat.school.payday[i + 1] = setting.stat.school.payday[i]
				setting.stat.school.auto[i + 1] = setting.stat.school.auto[i]
				setting.stat.school.moto[i + 1] = setting.stat.school.moto[i]
				setting.stat.school.fish[i + 1] = setting.stat.school.fish[i]
				setting.stat.school.swim[i + 1] = setting.stat.school.swim[i]
				setting.stat.school.gun[i + 1] = setting.stat.school.gun[i]
				setting.stat.school.hun[i + 1] = setting.stat.school.hun[i]
				setting.stat.school.exc[i + 1] = setting.stat.school.exc[i]
				setting.stat.school.taxi[i + 1] = setting.stat.school.taxi[i]
				setting.stat.school.meh[i + 1] = setting.stat.school.meh[i]
			end
			setting.stat.school.date_week[1] = os.date('%d.%m.%Y')
			setting.stat.school.payday[1] = 0
			setting.stat.school.auto[1] = 0
			setting.stat.school.moto[1] = 0
			setting.stat.school.fish[1] = 0
			setting.stat.school.swim[1] = 0
			setting.stat.school.gun[1] = 0
			setting.stat.school.hun[1] = 0
			setting.stat.school.exc[1] = 0
			setting.stat.school.taxi[1] = 0
			setting.stat.school.meh[1] = 0
		end
		for i = 1, 7 do
			setting.stat.school.total_week = setting.stat.school.payday[i] + setting.stat.school.auto[i] + setting.stat.school.moto[i] + 
			setting.stat.school.fish[i] + setting.stat.school.swim[i] + setting.stat.school.gun[i] + setting.stat.school.exc[i] + 
			setting.stat.school.taxi[i] + setting.stat.school.meh[i] + setting.stat.school.hun[i]
		end
		save('setting')
	end
	
	setting.online_stat.date_today[1] = tonumber(os.date('%d'))
	setting.online_stat.date_today[2] = tonumber(os.date('%m'))
	setting.online_stat.date_today[3] = tonumber(os.date('%Y'))
	if setting.online_stat.date_today[1] ~= setting.online_stat.date_last[1] or setting.online_stat.date_today[2] ~= setting.online_stat.date_last[2] 
	or setting.online_stat.date_today[3] ~= setting.online_stat.date_last[3] then
		setting.online_stat.date_num[1] = setting.online_stat.date_num[1] + 1
	end
	if setting.online_stat.date_num[1] > setting.online_stat.date_num[2] then --> Если сегодняшняя дата отличается от вчерашней
		setting.online_stat.date_last[1] = tonumber(os.date('%d'))
		setting.online_stat.date_last[2] = tonumber(os.date('%m'))
		setting.online_stat.date_last[3] = tonumber(os.date('%Y'))
		setting.online_stat.date_num[2] = setting.online_stat.date_num[1]
		for i = 6, 1, -1 do
			setting.online_stat.date_week[i + 1] = setting.online_stat.date_week[i]
			setting.online_stat.clean[i + 1] = setting.online_stat.clean[i]
			setting.online_stat.afk[i + 1] = setting.online_stat.afk[i]
			setting.online_stat.all[i + 1] = setting.online_stat.all[i]
		end
		setting.online_stat.date_week[1] = os.date('%d.%m.%Y')
		setting.online_stat.clean[1] = 0
		setting.online_stat.afk[1] = 0
		setting.online_stat.all[1] = 0
		save('setting')
	end
	
	start_pos = setting.start_pos
	new_pos = setting.new_pos
	interf = {
		main = {
			size = {x = 869, y = 469 + start_pos + new_pos},
			size_def = {x = 869, y = 469},
			anim_win = {move = false, par = false, x = 0, y = 0},
			func = true,
			cond = imgui.Cond.Always,
			collapse = false
		},
		list = ''
	}
	
	if setting.new_mus_fix then
		if #save_tracks.link ~= 0 then
			for i = 1, #save_tracks.link do
				if save_tracks.link[i]:find('ru%.apporange%.space') then
					save_tracks.link[i] = save_tracks.link[i]:gsub('ru%.apporange%.space', 'rur%.hitmotop%.com')
					save_tracks.image[i] = save_tracks.image[i]:gsub('ru%.apporange%.space', 'rur%.hitmotop%.com')
				end
			end
		end
		
		setting.new_mus_fix = false
		save('save_tracks')
		save('setting')
	end
	
	lua_thread.create(time)
	lua_thread.create(activate_function_members)
	lua_thread.create(save_coun_onl)
	lua_thread.create(update_check)
	lua_thread.create(time_potok)
	
	if #setting.cmd ~= 0 then
		for i = 1, #setting.cmd do
			sampRegisterChatCommand(setting.cmd[i][1], function(arg) cmd_start(arg, setting.cmd[i][1]) end)
		end
	end
	
	if #setting.lec ~= 0 then
		for i = 1, #setting.lec do
			sampRegisterChatCommand(setting.lec[i].cmd, function(arg) lec_start(arg, setting.lec[i].cmd) end)
		end
	end
	
	members_wait.members = true
	sampSendChat('/members')
	sampSendChat('/stats')
	
	style_window()
	
	while true do wait(0)
		if sampIsDialogActive() then
    		lastDialogWasActive = os.clock()
    	end
		res_targ, ped_tar = getCharPlayerIsTargeting(PLAYER_HANDLE)
		if res_targ then
			_, targ_id = sampGetPlayerIdByCharHandle(ped_tar)
			if setting.fast_acc.func and isKeyJustPressed(VK_R) and #setting.fast_acc.sl > 0 and targ_id ~= -1 then
				if sampIsPlayerConnected(targ_id) then
					flies_nick = sampGetPlayerNickname(targ_id)
					flies_id = targ_id
					win.action_choice.v = true
					imgui.ShowCursor = true
				end
			end
		end
		
		if secc_load_font and installation_success_font[1] and installation_success_font[2] then
			update_render_font()
			secc_load_font = false
		end
		
		imgui.Process = win.main.v or win.icon.v or win.spur_big.v or win.action_choice.v or win.reminder.v or win.notice.v or win.music.v
		
		if setting.time_hud and not isPauseMenuActive() then time_hud_func() end
		
		if setting.members.func and isCursorAvailable() and isKeyJustPressed(0xA5) then
			script_cursor = not script_cursor
			showCursor(script_cursor, false)
		end
		if setting.members.func and not isGamePaused() and not scene_active and ((setting.members.dialog and not sampIsDialogActive() and not sampIsCursorActive() and not sampIsChatInputActive() and not isSampfuncsConsoleActive()) or not setting.members.dialog) then
			render_members()
		elseif setting.members.func and pos_new_memb:status() ~= 'dead' then
			render_members()
		end
		
		if not win.main.v and not win.icon.v and not win.spur_big.v and not win.action_choice.v and not win.reminder.v then
			imgui.ShowCursor = false
		end
		
		if isKeyJustPressed(VK_NEXT) and not sampIsChatInputActive() and not sampIsDialogActive() and not isGamePaused() then
			if thread:status() ~= 'dead' then
				thread:terminate()
				new_notice('off')
			end
		end
		
		if not isGamePaused() and status_track_pl ~= 'STOP' then
			stalecatin()
		elseif isGamePaused() and status_track_pl == 'PLAY' then
			if get_status_potok_song() == 1 then
				bass.BASS_ChannelPause(stream_music)
			end
		end
		
		if scene_active or scene_edit_i or (preview_sc and edit_sc) then
			if not isGamePaused() then
				scene_work()
			end
		end
		
		if setting.rubber_stick then
			local num_weap = getCurrentCharWeapon(playerPed)
			if num_weap == 3 and not bool_rubber_stick then 
				sampSendChat('/me сняв дубинку с пояса, взял'.. chsex('', 'а') ..' её в правую руку')
				bool_rubber_stick = true
			elseif num_weap ~= 3 and bool_rubber_stick then
				sampSendChat('/me повесил'.. chsex('', 'а') ..' дубинку на пояс')
				bool_rubber_stick = false
			end
		end
	end
	
	
end

function time_potok()
	while true do wait(20)
		if status_track_pl == 'PLAY' then
			target_audio_vizual = audio_vizual
			local lengt = ffi.new("char[?]", 16)
			
			local gbit = bass.BASS_ChannelGetData(stream_music, lengt, 16)
			if gbit == 16 then
				local value = ffi.cast("int*", lengt)
				if tonumber(value[0]) > 0 then
					local kegla = tonumber(value[0])  / 42768000
					if kegla < 33 then
						audio_vizual = kegla
					end
				end

				ffi.fill(lengt, 16, 0)
			end
			
			level_potok = tonumber(bass.BASS_ChannelGetLevel(stream_music)) / 100000000
			
			if level_potok > 33 then level_potok = 33 end
			
			math.randomseed(os.time())
			local randomValue = math.random(50000000, 200000000)
			frequency = tonumber(bass.BASS_ChannelGetLevel(stream_music)) / randomValue
			
			if frequency > 33 then frequency = 33 end
		end
	end
end

function create_act(add_command)
	local function cr_file(name_file, content)
		if not doesFileExist(dirml..'/StateHelper/Отыгровки/'..name_file..'.json') then
			local f = io.open(dirml..'/StateHelper/Отыгровки/'..name_file..'.json', 'w')
			f:write(content)
			f:flush()
			f:close()
		end
	end
end

function new_frame_theme()
	if setting.int.theme == 'White' then
		if col_end.text > color_w.text then
			col_end.text = col_end.text - 0.035
		end
		
		if col_end.fond_one[1] < color_w.fond_one[1] then
			col_end.fond_one[1] = col_end.fond_one[1] + 0.035
		else
			col_end.fond_one[1] = color_w.fond_one[1]
		end
		if col_end.fond_one[2] < color_w.fond_one[2] then
			col_end.fond_one[2] = col_end.fond_one[2] + 0.035
		else
			col_end.fond_one[2] = color_w.fond_one[2]
		end
		if col_end.fond_one[3] < color_w.fond_one[3] then
			col_end.fond_one[3] = col_end.fond_one[3] + 0.035
		else
			col_end.fond_one[3] = color_w.fond_one[3]
		end
		
		if col_end.fond_two[1] < color_w.fond_two[1] then
			col_end.fond_two[1] = col_end.fond_two[1] + 0.035
		else
			col_end.fond_two[1] = color_w.fond_two[1]
		end
		if col_end.fond_two[2] < color_w.fond_two[2] then
			col_end.fond_two[2] = col_end.fond_two[2] + 0.035
		else
			col_end.fond_two[2] = color_w.fond_two[2]
		end
		if col_end.fond_two[3] < color_w.fond_two[3] then
			col_end.fond_two[3] = col_end.fond_two[3] + 0.035
		else
			col_end.fond_two[3] = color_w.fond_two[3]
		end
		style_window()
	else
		if col_end.text < color_b.text then
			col_end.text = col_end.text + 0.035
		end

		if col_end.fond_one[1] > color_b.fond_one[1] then
			col_end.fond_one[1] = col_end.fond_one[1] - 0.035
		else
			col_end.fond_one[1] = color_b.fond_one[1]
		end
		if col_end.fond_one[2] > color_b.fond_one[2] then
			col_end.fond_one[2] = col_end.fond_one[2] - 0.035
		else
			col_end.fond_one[2] = color_b.fond_one[2]
		end
		if col_end.fond_one[3] > color_b.fond_one[3] then
			col_end.fond_one[3] = col_end.fond_one[3] - 0.035
		else
			col_end.fond_one[3] = color_b.fond_one[3]
		end
		
		if col_end.fond_two[1] > color_b.fond_two[1] then
			col_end.fond_two[1] = col_end.fond_two[1] - 0.035
		else
			col_end.fond_two[1] = color_b.fond_two[1]
		end
		if col_end.fond_two[2] > color_b.fond_two[2] then
			col_end.fond_two[2] = col_end.fond_two[2] - 0.035
		else
			col_end.fond_two[2] = color_b.fond_two[2]
		end
		if col_end.fond_two[3] > color_b.fond_two[3] then
			col_end.fond_two[3] = col_end.fond_two[3] - 0.035
		else
			col_end.fond_two[3] = color_b.fond_two[3]
		end
		style_window()
	end
end

function imgui.OnDrawFrame()
	new_frame_theme()
	if win.main.v then
		if setting.int.first_start then
			window.main_first_start()
		else
			window.main()
		end
	end
	if win.icon.v then
		window.icon()
	end
	if win.notice.v then
		window.notice()
	end
	if win.action_choice.v then
		window.act_choice()
	end
	if win.spur_big.v then
		window.spur()
	end
	if win.reminder.v then
		window.reminder()
	end
	if win.music.v and status_track_pl ~= 'STOP' and setting.mus.win then
		window.music()
	end
end

local pos_win_closed
function styleAnimationOpen(win_name)
	if not setting.anim_main then
		local fps = mem.getfloat(0xB7CB50, true)
		local pert = 15
		if fps < 60 and fps >= 50 then
			pert = 20
		elseif fps < 50 and fps >= 40 then
			pert = 40
		elseif fps < 40 and fps >= 30 then
			pert = 70
		elseif fps < 30 then
			pert = 120
		end
		if win_name == 'Main' then
			interf.main.anim_win.y = sy / 2
			interf.main.anim_win.x = sx * 2
			
			lua_thread.create(function()
				interf.main.anim_win.move = true
				repeat wait(0)
					interf.main.anim_win.x = (interf.main.anim_win.x/1.04) - pert
				until interf.main.anim_win.x < sx / 2
				interf.main.anim_win.x = sx / 2
				interf.main.anim_win.move = false
			end)
		end
		imgui.ShowCursor = true
	else
		if win_name == 'Main' then
			interf.main.anim_win.y = sy / 2
			interf.main.anim_win.x = sx / 2
			imgui.ShowCursor = true
		end
	end
end

function styleAnimationClose(win_name, x_win, y_win)
	if not setting.anim_main then
		local fps = mem.getfloat(0xB7CB50, true)
		local pert = 18
		if fps < 60 and fps >= 50 then
			pert = 20
		elseif fps < 50 and fps >= 40 then
			pert = 40
		elseif fps < 40 and fps >= 30 then
			pert = 70
		elseif fps < 30 then
			pert = 120
		end
		if win_name == 'Main' then
			if not win.spur_big.v and not win.icon.v and not win.action_choice.v and not win.reminder.v then
				imgui.ShowCursor = false
			end
			interf.main.anim_win.y = pos_win_closed.y + (y_win / 2)
			if pos_win_closed.x > 0 then
				interf.main.anim_win.x = pos_win_closed.x + (x_win / 2)
			else
				interf.main.anim_win.x = x_win / 2
			end
			lua_thread.create(function()
				interf.main.anim_win.move = true
				repeat wait(0)
					interf.main.anim_win.x = (interf.main.anim_win.x * 1.04) + pert
				until interf.main.anim_win.x > sx + x_win
				win.main.v = false
				interf.main.anim_win.move = false
				imgui.ShowCursor = true
			end)
		end
	else
		if win_name == 'Main' then
			win.main.v = false
		end
	end
end


interface = {}

sampRegisterChatCommand('sh', function()
	if installation_success_font[1] and installation_success_font[2] then
		if not win.main.v then
			styleAnimationOpen('Main')
			win.main.v = true
		else
			interf.main.anim_win.par = true
		end
		if not setting.members.func then
			EXPORTS.sendRequest()
		end
		if IMG_No_Label == nil then
			IMG_No_Label = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/No label.png')
		end
		if IMG_Background == nil then
			IMG_Background = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Background.png')
		end
		if IMG_Background_White == nil then
			IMG_Background_White = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Background White.png')
		end
		if IMG_Background_Black == nil then
			IMG_Background_Black = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Background Black.png')
		end
		if #IMG_Record == 0 then
			IMG_Record = {
				[1] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Dance Label.png'),
				[2] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Megamix Label.png'),
				[3] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Party Label.png'),
				[4] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Phonk Label.png'),
				[5] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record GopFM Label.png'),
				[6] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Ruki Vverh Label.png'),
				[7] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Dupstep Label.png'),
				[8] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Bighits Label.png'),
				[9] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Organic Label.png'),
				[10] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Russianhits Label.png'),
			}
		end
	else
		sampAddChatMessage(script_tag..'{FFFFFF}Ошибка обнаружения шрифтов. Попробуйте снова через несколько секунд...', color_tag)
	end
end)

skin = {}
function skin.Button(text_button, x_button, y_button, x_size_button, y_size_button, function_button)
	local stylecol = false
	local invtext = false
	if x_size_button == nil then
		x_size_button = 100
	end
	if y_size_button == nil then
		y_size_button = 35
	end
	if text_button:find('false_func') then
		stylecol = true
		text_button = text_button:gsub('##false%_func', '')
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.60, 0.60, 0.60, 1.00))
		imgui.PushStyleColor(imgui.Col.ButtonHovered,imgui.ImVec4(0.60, 0.60, 0.60, 1.00))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
	end
	if text_button:find('false_non') then
		stylecol = true
		invtext = true
		text_button = text_button:gsub('##false%_non', '')
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.50, 0.50, 0.50, 0.30))
		imgui.PushStyleColor(imgui.Col.ButtonHovered,imgui.ImVec4(0.50, 0.50, 0.50, 0.30))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.50, 0.50, 0.50, 0.30))
	end
	local fiks_text = text_button
	if text_button:find('##') then
		text_button = text_button:gsub('##(.+)', '')
	end
	local calc = imgui.CalcTextSize(text_button)
	imgui.PushFont(font[1])
	imgui.SetCursorPos(imgui.ImVec2(x_button, y_button))
	if imgui.Button(u8'##'..fiks_text, imgui.ImVec2(x_size_button, y_size_button)) then
		if function_button ~= nil then
			function_button()
		end
	end
	if stylecol then
		imgui.PopStyleColor(3)
	end
	imgui.PopFont()
	
	imgui.SetCursorPos(imgui.ImVec2(x_button + ( (x_size_button/2) - calc.x / 2 ), y_button + (y_size_button / 2) - 8))
	if not invtext then
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
	else
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 0.30))
	end
	imgui.Text(text_button)
	imgui.PopStyleColor(1)
end

function skin.CheckboxOne(text_checkbox_one, x_pos_checkbox_one, y_pos_checkbox_one, param_checkbox_one) 
	local func_yes_or_no = false
	local non_text_checkbox = {}
	if setting.int.theme == 'White' then
		non_text_checkbox = {imgui.ImVec4(0.60, 0.60, 0.60, 1.00), imgui.ImVec4(0.70, 0.70, 0.70, 1.00)}
	else
		non_text_checkbox = {imgui.ImVec4(0.17, 0.17, 0.17, 1.00), imgui.ImVec4(0.27, 0.27, 0.27, 1.00)}
	end
	imgui.PushFont(font[1])
	imgui.SetCursorPos(imgui.ImVec2(x_pos_checkbox_one - 5, y_pos_checkbox_one - 2))
	if imgui.InvisibleButton(u8'##21'..text_checkbox_one, imgui.ImVec2(20, 20)) then func_yes_or_no = true end
	imgui.SetCursorPos(imgui.ImVec2(x_pos_checkbox_one + 5, y_pos_checkbox_one + 8))
	local p = imgui.GetCursorScreenPos()
	if imgui.IsItemActive() then
		if text_checkbox_one:find('false_func') then
			text_checkbox_one = text_checkbox_one:gsub('##false%_func', '')
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.3), 7, imgui.GetColorU32(non_text_checkbox[1]), 60)
		else
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.3), 7, imgui.GetColorU32(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00)), 60)
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.2, p.y + 0.3), 3.3, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.2, p.y + 0.3), 3.3, imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 60)
			end
		end
	else
		if text_checkbox_one:find('false_func') then
			text_checkbox_one = text_checkbox_one:gsub('##false%_func', '')
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.3), 8, imgui.GetColorU32(non_text_checkbox[2]), 60)
		else
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.3), 8, imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 60)
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.2, p.y + 0.3), 4, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.2, p.y + 0.3), 4, imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 60)
			end
		end
	end
	if text_checkbox_one:find('##') then
		text_checkbox_one = text_checkbox_one:gsub('##(.+)', '')
	end
	imgui.SetCursorPos(imgui.ImVec2(x_pos_checkbox_one + 20, y_pos_checkbox_one))
	imgui.Text(text_checkbox_one)
	imgui.PopFont()
	
	return func_yes_or_no
end

function skin.InputText(x_pos_input_text, y_pos_input_text, hint_text, arg_var_next_buf, buffer_size, input_text_size, filter_buf, saving_it, text_flag)
	local tbl_per = {}
	local arg_buf_format
	local saveinter
	local ret_enter = false
	if arg_var_next_buf:find('%.') then
		for word in arg_var_next_buf:gmatch('([%w_]+)%.?') do
			if word:find('^%d+$') then
				word = tonumber(word)
			end
			table.insert(tbl_per, word)
		end
	else
		tbl_per = {arg_var_next_buf}
	end
	if #tbl_per == 1 then
		arg_buf_format = imgui.ImBuffer(tostring(_G[tbl_per[1]]), buffer_size)
	elseif #tbl_per == 2 then
		arg_buf_format = imgui.ImBuffer(tostring(_G[tbl_per[1]][tbl_per[2]]), buffer_size)
	elseif #tbl_per == 3 then
		arg_buf_format = imgui.ImBuffer(tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]]), buffer_size)
	elseif #tbl_per == 4 then
		arg_buf_format = imgui.ImBuffer(tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]]), buffer_size)
	elseif #tbl_per == 5 then
		arg_buf_format = imgui.ImBuffer(tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]]), buffer_size)
	elseif #tbl_per == 6 then
		arg_buf_format = imgui.ImBuffer(tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]][tbl_per[6]]), buffer_size)
	end
	if arg_buf_format.v == 'nil' then
		arg_buf_format.v = ''
	end
	saveinter = arg_buf_format.v
	imgui.SetCursorPos(imgui.ImVec2(x_pos_input_text, y_pos_input_text - 3))
	local p = imgui.GetCursorScreenPos()
	imgui.SetCursorPos(imgui.ImVec2(x_pos_input_text, y_pos_input_text))
	if setting.int.theme == 'White' then
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + input_text_size, p.y + 28), imgui.GetColorU32(imgui.ImVec4(0.78, 0.78, 0.78, 1.00)), 8, 15)
	else
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + input_text_size, p.y + 28), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30, 1.00)), 8, 15)
	end
	imgui.PushItemWidth(input_text_size)
	imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
	if text_flag == 'enterflag' then
		if imgui.InputText('##'..u8(hint_text), arg_buf_format, imgui.InputTextFlags.EnterReturnsTrue) then ret_enter = true end
	else
		if filter_buf ~= nil then
			if filter_buf:find('num') then
				imgui.InputText('##'..u8(hint_text), arg_buf_format, imgui.InputTextFlags.CharsDecimal)
			else
				imgui.InputText('##'..u8(hint_text), arg_buf_format, imgui.InputTextFlags.CallbackCharFilter, filter(1, filter_buf))
			end
		else
			imgui.InputText('##'..u8(hint_text), arg_buf_format)
		end
	end
	
	if hint_text:find('##') then
		hint_text = hint_text:gsub('##(.+)', '')
	end
	imgui.PopStyleColor(1)
	imgui.SetCursorPos(imgui.ImVec2(x_pos_input_text + 10, y_pos_input_text + 2))
	if not imgui.IsItemActive() and arg_buf_format.v == '' then
		imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), hint_text)
	end
	if #tbl_per == 1 then
		_G[tbl_per[1]] = arg_buf_format.v
	elseif #tbl_per == 2 then
		_G[tbl_per[1]][tbl_per[2]] = arg_buf_format.v
	elseif #tbl_per == 3 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]] = arg_buf_format.v
	elseif #tbl_per == 4 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]] = arg_buf_format.v
	elseif #tbl_per == 5 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]] = arg_buf_format.v
	elseif #tbl_per == 6 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]][tbl_per[6]] = arg_buf_format.v
	end
	
	if saving_it ~= nil and arg_buf_format.v ~= saveinter then
		save(saving_it)
	end
	
	if ret_enter then return true else return false end
end

function skin.EmphText(text_emph, x_emph_text, y_emph_text, text_info)
	imgui.SetCursorPos(imgui.ImVec2(x_emph_text, y_emph_text))
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
	imgui.Text(text_emph)
	imgui.PopStyleColor(1)
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
	if imgui.IsItemHovered() and text_info ~= nil then
		imgui.SetTooltip(text_info)
	end
	imgui.PopStyleColor(1)
end

function skin.DrawFond(pos_draw, pos_plus_imvec2, size_plus_imvec2, col_draw_imvec4, radius_draw, flag_draw)
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + pos_plus_imvec2[1], p.y + pos_plus_imvec2[2]), imgui.ImVec2(p.x + size_plus_imvec2[1], p.y + size_plus_imvec2[2]), imgui.GetColorU32(col_draw_imvec4), radius_draw, flag_draw)
end

function skin.List(pos_s_list, select_s_list, all_s_list, length_s_list, par_znach)
	local find_check = select_s_list:gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%-', '%%-'):gsub('%.', '%%.')
	local tbl_per = {}
	if par_znach:find('%.') then
		for word in par_znach:gmatch('([%w_]+)%.?') do
			if word:find('^%d+$') then
				word = tonumber(word)
			end
			table.insert(tbl_per, word)
		end
	else
		tbl_per = {par_znach}
	end
	local gete_fg = false
	local func_true_or_false = false
	local num_sel_list = 1
	local calc = imgui.CalcTextSize(select_s_list)

	
	for b = 1, #all_s_list do
		if all_s_list[b]:find('^'..find_check..'$') then
			num_sel_list = b
		end
	end
	imgui.SetCursorPos(imgui.ImVec2(pos_s_list[1], pos_s_list[2]))
	if interf.list ~= select_s_list..pos_s_list[2] then
		if imgui.Button(u8'##t32y4'..select_s_list..all_s_list[1]..pos_s_list[1]..pos_s_list[2], imgui.ImVec2(length_s_list, 30)) then
			if interf.list ~= select_s_list..pos_s_list[1]..pos_s_list[2] then
				interf.list = select_s_list..pos_s_list[1]..pos_s_list[2]
				gete_fg = true
			else
				interf.list = ''
			end
		end
		imgui.PushFont(font[1])
		imgui.SetCursorPos(imgui.ImVec2(pos_s_list[1] - 2 + ( (length_s_list / 2) - calc.x / 2 ), pos_s_list[2] + (30 / 2) - 8))
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
		imgui.Text(select_s_list)
		imgui.PopStyleColor(1)
		imgui.PopFont()
	end

	imgui.SetCursorPos(imgui.ImVec2(pos_s_list[1], pos_s_list[2]))
	if interf.list == select_s_list..pos_s_list[1]..pos_s_list[2] then
		imgui.SetCursorPos(imgui.ImVec2(pos_s_list[1], pos_s_list[2]))
		imgui.BeginChild(select_s_list..all_s_list[1]..pos_s_list[1]..pos_s_list[2], imgui.ImVec2(length_s_list, (#all_s_list + 1) * 30), false, imgui.WindowFlags.NoScrollbar)
			imgui.SetCursorPos(imgui.ImVec2(0, 0))
			if imgui.InvisibleButton(u8'##t32y4'..select_s_list..all_s_list[1]..pos_s_list[1]..pos_s_list[2], imgui.ImVec2(length_s_list, 30)) and not gete_fg then
				interf.list = ''
			end
			imgui.SetCursorPos(imgui.ImVec2(0, 0))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 8, 3)
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(- 2 + ( (length_s_list / 2) - calc.x / 2 ), (30 / 2) - 8))
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
			imgui.Text(select_s_list)
			imgui.PopStyleColor(1)
			imgui.PopFont()
			
			for n = 1, #all_s_list do
				imgui.SetCursorPos(imgui.ImVec2(0, 30 * n))
				local p = imgui.GetCursorScreenPos()
				local get_w_d_l = imgui.ImVec4(0.30, 0.30, 0.30, 0.95)
				local get_w_d_l_c = imgui.ImVec4(0.20, 0.20, 0.20, 0.99)
				local get_w_d_l_c_line = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
				if setting.int.theme == 'White' then
					get_w_d_l = imgui.ImVec4(0.75, 0.75, 0.75, 0.95)
					get_w_d_l_c = imgui.ImVec4(0.65, 0.65, 0.65, 0.99)
					get_w_d_l_c_line = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
				end
				if n == 1 then
					imgui.SetCursorPos(imgui.ImVec2(0, 30 * n))
					if imgui.InvisibleButton(u8'##t32ky4'..select_s_list..all_s_list[1]..n..pos_s_list[1]..pos_s_list[2], imgui.ImVec2(length_s_list, 30)) then select_s_list = all_s_list[n] func_true_or_false = true interf.list = '' end
					if imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(get_w_d_l_c), 0, 0)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(get_w_d_l), 0, 0)
					end
					if not imgui.IsItemHovered() then
						
					end
					imgui.SetCursorPos(imgui.ImVec2(0, (30 * n) + 30))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 1), imgui.GetColorU32(get_w_d_l_c_line), 0, 0)
				elseif n ~= #all_s_list then
					imgui.SetCursorPos(imgui.ImVec2(0, 30 * n))
					if imgui.InvisibleButton(u8'##t32ky4'..select_s_list..all_s_list[1]..n..pos_s_list[1]..pos_s_list[2], imgui.ImVec2(length_s_list, 30)) then select_s_list = all_s_list[n] func_true_or_false = true interf.list = '' end
					if imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(get_w_d_l_c), 0, 0)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(get_w_d_l), 0, 0)
					end
					
					imgui.SetCursorPos(imgui.ImVec2(0, (30 * n) + 30))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 1), imgui.GetColorU32(get_w_d_l_c_line), 0, 0)
				elseif n == #all_s_list then
					imgui.SetCursorPos(imgui.ImVec2(0, 30 * n))
					if imgui.InvisibleButton(u8'##t32ky4'..select_s_list..all_s_list[1]..n..pos_s_list[1]..pos_s_list[2], imgui.ImVec2(length_s_list, 30)) then select_s_list = all_s_list[n] func_true_or_false = true interf.list = '' end
					if imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(get_w_d_l_c), 8, 12)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(get_w_d_l), 8, 12)
					end
				end
				
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(27, (30 * n) + 6))
				imgui.Text(all_s_list[n])
				imgui.PopFont()
				
				if num_sel_list == n then
					imgui.PushFont(fa_font[4])
					imgui.SetCursorPos(imgui.ImVec2(6, (30 * n) + 6))
					imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_CHECK)
					imgui.PopFont()
				end
			end
		imgui.EndChild()
	end
	if imgui.IsMouseReleased(0) and not imgui.IsItemHovered() and interf.list == select_s_list..pos_s_list[1]..pos_s_list[2] then
		interf.list = ''
	end
	if func_true_or_false then
		if #tbl_per == 1 then
			_G[tbl_per[1]] = select_s_list
		elseif #tbl_per == 2 then
			_G[tbl_per[1]][tbl_per[2]] = select_s_list
		elseif #tbl_per == 3 then
			_G[tbl_per[1]][tbl_per[2]][tbl_per[3]] = select_s_list
		elseif #tbl_per == 4 then
			_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]] = select_s_list
		elseif #tbl_per == 5 then
			_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]] = select_s_list
		elseif #tbl_per == 6 then
			_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]][tbl_per[6]] = select_s_list
		end
	end
	
	return func_true_or_false
end

function skin.Switch(namebut, bool)
    local rBool = false
    if LastActiveTime == nil then
        LastActiveTime = {}
    end
    if LastActive == nil then
        LastActive = {}
    end
    local function ImSaturate(f)
        return f < 0.06 and 0.06 or (f > 1.0 and 1.0 or f)
    end
    local p = imgui.GetCursorScreenPos()
    local draw_list = imgui.GetWindowDrawList()
    local height = imgui.GetTextLineHeightWithSpacing() * 1.15
    local width = height * 1.35
    local radius = height * 0.30
    local ANIM_SPEED = 0.09
    local butPos = imgui.GetCursorPos()
    if imgui.InvisibleButton(namebut, imgui.ImVec2(width, height)) then
        bool = not bool
        rBool = true
        LastActiveTime[tostring(namebut)] = os.clock()
        LastActive[tostring(namebut)] = true
    end
    imgui.SetCursorPos(imgui.ImVec2(butPos.x + width + 3, butPos.y + 3.8))
    imgui.Text( namebut:gsub('##.+', ''))
    local t = bool and 1.0 or 0.06
    if LastActive[tostring(namebut)] then
        local time = os.clock() - LastActiveTime[tostring(namebut)]
        if time <= ANIM_SPEED then
            local t_anim = ImSaturate(time / ANIM_SPEED)
            t = bool and t_anim or 1.0 - t_anim
        else
            LastActive[tostring(namebut)] = false
        end
    end
	local col_neitral = 0xFF606060
	if setting.int.theme == 'White' then
		col_neitral =  0xFFD4CFCF
	end
    local col_static = 0xFFFFFFFF
    local col = bool and imgui.ColorConvertFloat4ToU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)) or col_neitral
    draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col, 7.0)
    draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.3), p.y + 4 + radius), radius - 0.75, col_static)

    return rBool
end

function skin.Slider(slider_text, slider_arg, slider_min, slider_max, slider_width, slider_pos, saving_it)
	local function convert(param)
		param = tonumber(param) * 100
		return round(param, 1)
	end
	local tbl_per = {}
	local arg_buf_format
	local pere_arg
	local saveinter
	local tap_slid = false
	if slider_arg:find('%.') then
		for word in slider_arg:gmatch('([%w_]+)%.?') do
		if word:find('^%d+$') then
			word = tonumber(word)
		end
		   table.insert(tbl_per, word)
		end
	else
		tbl_per = {slider_arg}
	end
	if #tbl_per == 1 then
		pere_arg = tostring(_G[tbl_per[1]])
	elseif #tbl_per == 2 then
		pere_arg = tostring(_G[tbl_per[1]][tbl_per[2]])
	elseif #tbl_per == 3 then
		pere_arg = tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]])
	elseif #tbl_per == 4 then
		pere_arg = tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]])
	elseif #tbl_per == 5 then
		pere_arg = tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]])
	elseif #tbl_per == 6 then
		pere_arg = tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]][tbl_per[6]])
	end
	arg_buf_format = tonumber(pere_arg)
	arg_buf_format = imgui.ImFloat(arg_buf_format)
	if arg_buf_format.v == 'nil' then
		arg_buf_format.v = ''
	end
	saveinter = arg_buf_format.v

	local slider_width_end = (slider_width-15) / slider_max
	imgui.SetCursorPos(imgui.ImVec2(slider_pos[1]+5, slider_pos[2]+9))
	local p = imgui.GetCursorScreenPos()
	local DragPos = imgui.GetCursorPos()
	imgui.SetCursorPos(imgui.ImVec2(slider_pos[1], slider_pos[2]))
	imgui.PushItemWidth(slider_width)
	imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(0, 0, 0, 0):GetVec4())
	imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(0, 0, 0, 0):GetVec4())
	imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(0, 0, 0, 0):GetVec4())
	imgui.SliderFloat(u8'##'..slider_text, arg_buf_format, slider_min, slider_max, u8'')
	imgui.PopStyleColor(3)
	
	local col_sl_non = imgui.ImVec4(0.60, 0.60, 0.60 ,1.00)
	local col_sl_circle = imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)
	if setting.int.theme == 'White' then
		col_sl_non = imgui.ImVec4(0.83, 0.81, 0.81 ,1.00)
	end
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + slider_width - 15, p.y + 5), imgui.GetColorU32(col_sl_non), 10, 15)
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + (arg_buf_format.v * slider_width_end), p.y + 5), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3] ,1.00)), 10, 15)
	imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + (arg_buf_format.v * slider_width_end), p.y + 2), 9, imgui.GetColorU32(col_sl_circle))
	imgui.SameLine()
	if not slider_text:find('##') then
		imgui.PushFont(font[1])
		imgui.Text(slider_text)
		imgui.PopFont()
	end
	
	if #tbl_per == 1 then
		_G[tbl_per[1]] = arg_buf_format.v
	elseif #tbl_per == 2 then
		_G[tbl_per[1]][tbl_per[2]] = arg_buf_format.v
	elseif #tbl_per == 3 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]] = arg_buf_format.v
	elseif #tbl_per == 4 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]] = arg_buf_format.v
	elseif #tbl_per == 5 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]] = arg_buf_format.v
	elseif #tbl_per == 6 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]][tbl_per[6]] = arg_buf_format.v
	end
	
	if saving_it ~= nil and arg_buf_format.v ~= saveinter then
		save(saving_it)
		tap_slid = true
	end
	
	return tap_slid
end


sampRegisterChatCommand('ic', function() win.icon.v = not win.icon.v end)
window = {}
function window.main_first_start()
	imgui.SetNextWindowPos(imgui.ImVec2(interf.main.anim_win.x, interf.main.anim_win.y), interf.main.cond, imgui.ImVec2(0.5, 0.5)) -- 
	imgui.SetNextWindowSize(imgui.ImVec2(interf.main.size.x, interf.main.size.y))
	imgui.Begin('Window Main first start', false, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
	if interf.main.func or interf.main.anim_win.move then
		interf.main.cond = imgui.Cond.Always
	else
		interf.main.cond = imgui.Cond.FirstUseEver
	end
	if interf.main.func then
		interf.main.func = false
	end
	
	skin.DrawFond({4, 4}, {0, 0}, {860, 460}, imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00), 15, 15)
	imgui.SetCursorPos(imgui.ImVec2(13, 13))
	if imgui.InvisibleButton(u8'##Закрыть окно', imgui.ImVec2(20, 20)) or interf.main.anim_win.par  then
		pos_win_closed = imgui.GetWindowPos()
		styleAnimationClose('Main', interf.main.size.x, interf.main.size.y)
		interf.main.anim_win.par = false
	end
	imgui.SetCursorPos(imgui.ImVec2(23, 23))
	local p = imgui.GetCursorScreenPos()
	if imgui.IsItemHovered() then
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
		imgui.SetCursorPos(imgui.ImVec2(19, 16))
		imgui.PushFont(fa_font[2])
		imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
		imgui.PopFont()
	else
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
	end
	
	if not first_start_anim.text[1] and not first_start_anim.done[1] then
		first_start_anim.text[1] = true
	end
	
	if first_start_anim.text[2] or first_start_anim.text[3] or first_start_anim.text[4] or first_start_anim.text[5] or first_start_anim.text[6]then
		local function text_big_main_screen(text_big, vis_texte)
			imgui.PushFont(bold_font[2])
			local calc = imgui.CalcTextSize(text_big)
			imgui.SetCursorPos(imgui.ImVec2((434 - calc.x / 2 ), first_start_anim.pos[2]))
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, vis_texte), text_big)
			imgui.PopFont()
		end
		if first_start_anim.text[2] then
			text_big_main_screen(u8'Выберите оформление', first_start_anim.vis[2])
		elseif first_start_anim.text[3] then
			text_big_main_screen(u8'Уточните организацию', 1.00)
		elseif first_start_anim.text[4] then
			text_big_main_screen(u8'Ваш никнейм на русском', 1.00)
		elseif first_start_anim.text[5] then
			text_big_main_screen(u8'Пользовательское соглашение', first_start_anim.vis[2])
		elseif first_start_anim.text[6] then
			text_big_main_screen(u8'Обновления', first_start_anim.vis[2])
		end
	end
	if first_start_anim.text[1] then
		imgui.PushFont(bold_font[2])
		imgui.SetCursorPos(imgui.ImVec2(338, 200))
		imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, first_start_anim.vis[1]), u8'Привет')
		imgui.PopFont()
		if first_start_anim.vis[1] < 1.6 and not first_start_anim.done[1] then
			first_start_anim.vis[1] = first_start_anim.vis[1] + 0.009
		else
			first_start_anim.done[1] = true
			first_start_anim.vis[1] = first_start_anim.vis[1] - 0.009
			if first_start_anim.vis[1] < 0 then
				first_start_anim.text[1] = false
				first_start_anim.text[2] = true
			end
		end
	end
	if first_start_anim.text[2] then
		if first_start_anim.vis[2] < 1.6 and not first_start_anim.done[2] then
			first_start_anim.vis[2] = first_start_anim.vis[2] + 0.009
		else
			if first_start_anim.pos[2] > 80 then
				first_start_anim.pos[2] = first_start_anim.pos[2] - 3.5
			else
				if buf_setting.theme[1].v then
					skin.DrawFond({199, 169}, {- 1.0,- 0.8}, {203, 112}, imgui.ImVec4(0.26, 0.50, 0.94, 1.00), 15, 15)
				end
				if buf_setting.theme[2].v then
					skin.DrawFond({469, 169}, {- 1.0, - 0.8}, {203, 112}, imgui.ImVec4(0.26, 0.50, 0.94, 1.00), 15, 15)
				end
				skin.DrawFond({200, 170}, {0, 0}, {200, 109}, imgui.ImVec4(1.00, 1.00, 1.00, 1.00), 15, 15)
				skin.DrawFond({200, 170}, {0, 0}, {40, 109}, imgui.ImVec4(0.91, 0.89, 0.76, 0.80), 15, 9)
				
				skin.DrawFond({205, 185}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
				skin.DrawFond({205, 208}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
				skin.DrawFond({205, 231}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
				skin.DrawFond({205, 255}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
				skin.DrawFond({300, 185}, {0, 0}, {40, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
				skin.DrawFond({250, 208}, {0, 0}, {130, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
				skin.DrawFond({250, 231}, {0, 0}, {70, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
				skin.DrawFond({250, 255}, {0, 0}, {110, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
				
				skin.DrawFond({470, 170}, {0, 0}, {200, 109}, imgui.ImVec4(0.08, 0.08, 0.08, 1.00), 15, 15)
				skin.DrawFond({470, 170}, {0, 0}, {40, 109}, imgui.ImVec4(0.15, 0.13, 0.13, 0.70), 15, 9)
				
				skin.DrawFond({475, 185}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
				skin.DrawFond({475, 208}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
				skin.DrawFond({475, 231}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
				skin.DrawFond({475, 255}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
				skin.DrawFond({570, 185}, {0, 0}, {40, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
				skin.DrawFond({520, 208}, {0, 0}, {130, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
				skin.DrawFond({520, 231}, {0, 0}, {70, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
				skin.DrawFond({520, 255}, {0, 0}, {110, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
				
				if not buf_setting.theme[1].v then
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgHovered,imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0.40, 0.40, 0.40, 1.00))
				else
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00))
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(274, 300))
				imgui.Text(u8'Светлое')
				
				if buf_setting.theme[1].v then
					if skin.CheckboxOne(u8'##whitebox', 295, 330) then
						
					end
				else
					if skin.CheckboxOne(u8'##whitebox##false_func', 295, 330) then
						buf_setting.theme[1].v = true
						buf_setting.theme[2].v = false
						setting.int.theme = 'White'
					end
				end
				imgui.PopStyleColor(3)
				if not buf_setting.theme[2].v then
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgHovered,imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0.40, 0.40, 0.40, 1.00))
				else
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00))
				end
				
				imgui.SetCursorPos(imgui.ImVec2(546, 300))
				imgui.Text(u8'Тёмное')
				if buf_setting.theme[2].v then
					if skin.CheckboxOne(u8'##blackebox', 565, 330) then
						
					end
				else
					if skin.CheckboxOne(u8'##blackbox##false_func', 565, 330) then
						buf_setting.theme[1].v = false
						buf_setting.theme[2].v = true
						setting.int.theme = 'Black'
					end
				end
				imgui.PopStyleColor(3)
				
				skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
				skin.Button(u8'Продолжить', 630, 400, nil, nil, function() 
					first_start_anim.text[2] = false
					first_start_anim.text[3] = true
				end)
				skin.Button(u8'Назад##false_non', 515, 400, nil, nil, function() end)
				skin.EmphText(u8'Узнать подробнее', 140, 410, u8'Выбранная тема оформления будет отображаться\nво всех окнах программы.\n\nТему можно будет изменить в настройках.')
				imgui.PopFont()
			end
		end
	end
	if first_start_anim.text[3] then
		local carta_org = {u8'Больница ЛС', u8'Больница ЛВ', u8'Больница СФ', u8'Больница Джефферсон', u8'Центр Лицензирования', u8'Центральный Банк'}
		for i = 1, #carta_org do
			if num_of_the_selected_org == i then
				setting.frac.org = carta_org[i]
			end
		end
		imgui.PushFont(font[1])
		if num_of_the_selected_org == 1 then
			if skin.CheckboxOne(u8'Больница ЛС', 350, 177) then num_of_the_selected_org = 1 setting.frac.org = u8'Больница ЛС' end
		else
			if skin.CheckboxOne(u8'Больница ЛС##false_func', 350, 177) then num_of_the_selected_org = 1 setting.frac.org = u8'Больница ЛС' end
		end
		if num_of_the_selected_org == 2 then
			if skin.CheckboxOne(u8'Больница ЛВ', 350, 206) then num_of_the_selected_org = 2 setting.frac.org = u8'Больница ЛВ' end
		else
			if skin.CheckboxOne(u8'Больница ЛВ##false_func', 350, 206) then num_of_the_selected_org = 2 setting.frac.org = u8'Больница ЛВ' end
		end
		if num_of_the_selected_org == 3 then
			if skin.CheckboxOne(u8'Больница СФ', 350, 235) then num_of_the_selected_org = 3 setting.frac.org = u8'Больница СФ' end
		else
			if skin.CheckboxOne(u8'Больница СФ##false_func', 350, 235) then num_of_the_selected_org = 3 setting.frac.org = u8'Больница СФ' end
		end
		if num_of_the_selected_org == 4 then
			if skin.CheckboxOne(u8'Больница Джефферсон', 350, 263) then num_of_the_selected_org = 4 setting.frac.org = u8'Больница Джефферсон' end
		else
			if skin.CheckboxOne(u8'Больница Джефферсон##false_func', 350, 263) then num_of_the_selected_org = 4 setting.frac.org = u8'Больница Джефферсон' end
		end
		if num_of_the_selected_org == 5 then
			if skin.CheckboxOne(u8'Центр Лицензирования', 350, 292) then num_of_the_selected_org = 5 setting.frac.org = u8'Центр Лицензирования' end
		else
			if skin.CheckboxOne(u8'Центр Лицензирования##false_func', 350, 292) then num_of_the_selected_org = 5 setting.frac.org = u8'Центр Лицензирования' end
		end
		if num_of_the_selected_org == 6 then
			if skin.CheckboxOne(u8'Центральный Банк', 350, 321) then num_of_the_selected_org = 6 setting.frac.org = u8'Центральный Банк' end
		else
			if skin.CheckboxOne(u8'Центральный Банк##false_func', 350, 321) then num_of_the_selected_org = 6 setting.frac.org = u8'Центральный Банк' end
		end
		skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
		skin.Button(u8'Продолжить', 630, 400, nil, nil, function() 
			first_start_anim.text[3] = false
			first_start_anim.text[4] = true
		end)
		skin.Button(u8'Назад', 515, 400, nil, nil, function()
			first_start_anim.text[2] = true
			first_start_anim.text[3] = false
		end)
		skin.EmphText(u8'Узнать подробнее', 140, 410, u8'Выберите организацию, в которой Вы состоите на данный момент.\nЭто поможет настроить хелпер под Ваши задачи.')
		imgui.PopFont()
	end
	if first_start_anim.text[4] then
		imgui.PushFont(font[1])
		skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
		if not setting.nick:find('%S+%s+%S+') then
			skin.Button(u8'Продолжить##false_non', 630, 400, nil, nil, function() end)
		else
			skin.Button(u8'Продолжить', 630, 400, nil, nil, function() 
				first_start_anim.text[4] = false
				first_start_anim.text[5] = true
			end)
		end
		skin.Button(u8'Назад', 515, 400, nil, nil, function()
			first_start_anim.text[3] = true
			first_start_anim.text[4] = false
		end)
		skin.EmphText(u8'Узнать подробнее', 140, 410, u8'Введите в поле ввода Ваш никнейм на русском языке.\nНапример, Альберто Кейн')
		local my_nickname = sampGetPlayerNickname(my.id):gsub('_',' ')
		skin.InputText(255, 255, u8'Ваш ник '..my_nickname..u8' на русском', 'setting.nick', 74, 350, '[а-Я%s]+')
		imgui.PopFont()
	end
	
	if first_start_anim.text[5] then
		imgui.PushFont(font[1]) -- imgui.TextWrapped(u8'')
		imgui.SetCursorPos(imgui.ImVec2(134, 150))
		imgui.BeginChild(u8'Пользовательское соглашение', imgui.ImVec2(600, 217), false)
		imgui.PushFont(font[4])
		imgui.Text(u8'1. Основные термины и определения')
		imgui.PopFont()
		imgui.TextWrapped(u8'1.1 Правообладатель - ИТД Марсель Афанасьев: это лицо, которое обладает правами собственности на интеллектуальную собственность, такую как авторские права, патенты, торговые марки и другие права, связанные с созданием и использованием интеллектуальных продуктов или изобретений. Термин "Правообладатель" также включает в себя разработчика, менеджера, директора, поставщика и других ответственных сторон, участвующих в создании, управлении и поставке Программы (см. определение ниже). Это объединяющий термин, включающий все заинтересованные стороны, которые имеют право предоставлять разрешения на использование Программы (см. определение ниже) и управлять правами доступа в соответствии с данным Лицензионным соглашением (данный договор между двумя сторонами: (Пользователь (см. определение ниже) и Правообладатель), далее "Соглашение").\nПравообладателем данной Программы (см. определение ниже), а также официальным обладателем авторских прав и интеллектуальной собственности, является единственное лицо. Все иные лица, причастные к созданию, разработке, поддержке и другим терминам включающих в себя определение из термина Правообладателя, за исключением правами собственности на интеллектуальную собственность, такую как авторские права, патенты, торговые марки и другие права, связанные с созданием и использованием интеллектуальных продуктов или изобретений данного программного обеспечения (далее "ПО"), являются партнёрами (далее "Партнёр", "Партнёры") Правообладателя.\n')
		imgui.TextWrapped(u8'Термин относится к ПО, в котором находится данное Лицензионное соглашение или на одном виртуальном, облачном или удалённом носителе, учётной записи одного Пользователя всего ресурса, сайта или хранилища, на котором расположено ПО.\n\n')
		imgui.TextWrapped(u8'1.2 Программа - это ПО, принадлежащее Правообладателю, которое было приобретено и установлено на Носитель (см. определение ниже) технического устройства. Из списка выпущенных Правообладателем Программ, данный термин относится ко всем ПО, включающих в своём названии словосочетание "State Helper", написанное на английском языке в любом из возможных вариантов регистра букв.\nНаименование ПО можно найти в свойствах файла установленного с источников Правообладателя в случае, если файл не был отредактирован в последствии перемещения его на Носитель (см. определение ниже) технического устройства.\n\n')
		imgui.TextWrapped(u8'1.3 Носитель - устройство или средство, используемое для хранения и передачи данных. Это может быть физический объект, такой как жёсткий диск, USB-флешка, CD, DVD, Blu-ray диск или другие съёмные устройства хранения информации.\n\n1.4 Arizona Role Play - это проект ролевой игры (Role-Play) на платформе SA:MP (San Andreas Multiplayer), принадлежащий игровой компании Arizona Games. В этом проекте игроки могут взаимодействовать в виртуальном мире, исполняя определенные роли и выполняя задания в атмосфере, созданной на базе игры Grand Theft Auto: San Andreas с использованием мультиплеерной платформы SA:MP.\n\n1.5 Руководство пользователя - документ, который содержит инструкцию о том, как правильно использовать Программу, предоставленную Правообладателем.\n\n1.6 Пользователь - человек, установивший или использующий Программу, предоставленную Правообладателем.\n\n1.7 Блокировка программы - это техническая или программная мера, которая преднамеренно ограничивает доступ Пользователя к определенным функциям, данным или ресурсам Программы.\n\n1.8 Интернет - информационно-телекоммуникационная сеть, т. е. технологическая система, предназначенная для передачи по линиям связи информации, доступ к которой осуществляется с использованием средств вычислительной техники.\n\n1.9 Установка - процесс размещения Программы на компьютере или устройстве, чтобы она стала доступной и готовой к использованию. Во время установки происходит копирование файлов Программы на жёсткий диск или другое физическое хранилище, кроме тех, доступ к которым требует наличия Интернета.\n\n')
		imgui.TextWrapped(u8'1.10 Игра - конкретный вид развлекательной деятельности, не связанный с непосредственными задачами жизнеобеспечения, выполняющий функции заполнения досуга человека.\n\n1.11 Версия программы - присвоенный номер Программы, позволяющий определить новизну ПО, т. е. дату его выхода, а также различия относительно предыдущих версий Программы.\nВерсия программы отображена в самой Программе под соответствующим названием включающая в своём словосочетании слово "Версия".\n\n1.12 Закрытое тестирование - процесс исследования, испытания ПО, имеющий своей целью проверку соответствия между реальным поведением программы и её ожидаемым поведением на конечном наборе тестов, выбранных определённым образом.\nПроцесс осуществляется без учёта возможности публикации такого ПО в общий доступ, дающий возможность любому Пользователю осуществить установку ПО.\nТермин применяется к Программе, имеющей в своём программном коде заданную условную переменную "Beta" не соответствующей второму числу текущей Версии программы.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'2. Лицензия')
		imgui.PopFont()
		imgui.TextWrapped(u8'2.1 Правообладатель предоставляет Вам неисключительную лицензию на использование Программы для упрощения процесса Игры на проекте Arizona Role Play, описанных в Руководстве пользователя, при условии, в котором Вами соблюдены все необходимые требования, описанные в Руководстве пользователя, а также всех ограничений и условий использования Программы, указанных в настоящем Соглашении.\nВ случае использования Программы для тестирования функциональности, Правообладатель предоставляет Вам неисключительную лицензию на тестирование программы при условии соблюдения Вами всех необходимых требований, описанных в Руководстве пользователя, а также всех ограничений и условий использования Программы, указанных в настоящем Соглашении.\n\n')
		imgui.TextWrapped(u8'2.2 При соблюдении определённых условий Вы можете создать копию программы типа "Закрытое тестирование" с единственной целью архивирования и замены правомерно установленного экземпляра в случае его утери, уничтожения или непригодности. Тем не менее, использование такой копии для иных целей запрещено, и владение ею должно прекратиться, если обладание правомерным экземпляром программы прекращается.\n\n')
		imgui.TextWrapped(u8'2.3 После установки программы Вам, по возможности, предоставляется право получать от Правообладателя или его Партнёров:\n- новые версии ПО по мере их выхода (через Интернет)\n- техническую поддержку (через Интернет)\n- доступ к информационным и вспомогательным ресурсам Правообладателя.\nДанные возможности не могут быть гарантированы Правообладателем и в праве перестать быть доступными любому Пользователю Программы в любой момент времени без объяснения причин.\n\n')
		imgui.TextWrapped(u8'2.4 В случае установки Программы типа "Закрытое тестирование" через Интернет, Вы имеете право использовать такую копию Программы исключительно на одном техническом устройстве или Ностеле. Количество созданных копий Программы на одном устройстве неограниченно. Запрещается создавать, распространять, передавать копию такой Программы через облачные хранилища, где доступ к ней могут получить другие лица, кроме Вас. Запрещается копировать такую Программу на носитель, физический доступ к которому у Вас отсутствует. Запрещено устанавливать такую копию Программу на любой носитель с источников, не включённых в перечень, описанный в данном Соглашении.\n\n')
		imgui.TextWrapped(u8'2.5 Программа считается установленной с момента её размещения на Носитель Пользователя, независимо от того, запущена она впоследствии Пользователем или нет.\n\n')
		
		imgui.PushFont(font[4])
		imgui.Text(u8'3. Обновления')
		imgui.PopFont()
		imgui.TextWrapped(u8'После установки программы на Носитель, Правообладатель предоставляет возможность Пользователям выбирать способ обновления Программы. Если Пользователь сам решит использовать автоматическое обновление, поставив соответствующую галочку в самой Программе, тогда обновления будут проводиться без дополнительного разрешения или согласия с его стороны.\n\nВ противном случае, если Пользователь не выбрал автоматическое обновление, процесс установки обновления будет требовать подтверждения Пользователя в самой Программе. Пользователю будет предоставлена возможность ознакомиться с деталями обновления и дать согласие на его установку перед началом процесса.\n\n')
		imgui.TextWrapped(u8'Независимо от выбранного способа обновления, каждое обновление будет регулироваться настоящим Соглашением, а содержание, функции и возможности обновленной Программы определяются исключительно Правообладателем. Эти обновления могут включать как добавление, так и удаление функций Программы, а также полную замену Программы. При этом Вам может быть ограничено использование Программы или устройства (включая определенные функции) до тех пор, пока обновление не будет полностью установлено или активировано.\n\nПравообладатель может прекратить предоставление поддержки Программы, пока Вы не установите все доступные обновления. Необходимость и периодичность предоставления обновлений определяется Правообладателем по его усмотрению, и Правообладатель не обязан предоставлять Вам обновления. Также Правообладатель может прекратить предоставление обновлений для версий Программы, отличных от наиболее новой версии, или для обновлений, которые не поддерживают использование Программы с различными версиями операционных систем или другим ПО.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'4. Права собственности')
		imgui.PopFont()
		imgui.TextWrapped(u8'4.1 Программа и её программный код являются интеллектуальной собственностью Правообладателя и защищены применимым авторским правом, а также международными договорами и законодательством Российской Федерации. Если Вы являетесь Пользователем, установившим Программу на законных основаниях, то Вы имеете право просматривать открытый программный код Программы. Предоставляя свои комментарии и предложения, касающиеся Программы, Вы предоставляете Правообладателю разрешение на их использование при разработке своих настоящих или будущих продуктов или услуг. При этом, Вы соглашаетесь, что такое использование не потребует выплаты компенсации и дополнительного разрешения от Вас на хранение или использование Ваших материалов.\n\n')
		imgui.TextWrapped(u8'4.2 Помимо указанных в настоящем Соглашении, владение Программой и её использование не предоставляют Вам какие-либо права на Программу или программный код, включая авторские права, патенты, торговые знаки и другие права интеллектуальной собственности. Все такие права полностью принадлежат Правообладателю Программы.\n\n')
		imgui.TextWrapped(u8'4.3 Вы не имеете права копировать или использовать Программу или её программный код, за исключением случаев, описанных в разделе 2 настоящего Соглашения.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'5. Конфиденциальность')
		imgui.PopFont()
		imgui.TextWrapped(u8'Вы даете Правообладателю и партнёрам Правообладателя согласие на использование Ваших данных в соответствии с политикой конфиденциальности. Вы осознаете, что Ваши данные будут использоваться для различных целей, таких как обработка событий использования Программы, улучшения Программы, предоставления Вам информации об установленной Программе и предложение Вам других Программ.\n\nВы также подтверждаете, что Правообладатель может передавать Ваши данные партнёрам Правообладателя, таким как поставщики платформы электронной коммерции, обработчики платежей, поставщики поддержки, услуг и Программ от имени Правообладателя, а также поставщики, предоставляющие Правообладателю или партнёрам Правообладателя аналитические данные о покупках и сбоях в работе Программы.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'6. Прекращение действия')
		imgui.PopFont()
		imgui.TextWrapped(u8'6.1 Если Вы нарушите любое из обязательств, установленных в данном соглашении, включая обязательства, определённые в разделах 2 или 5, настоящее Соглашение автоматически прекратится и Вы лишитесь права на получение обновлений Программы. При возникновении нарушения, которое причинило ущерб Правообладателю, Правообладатель имеет право обратиться к законным средствам защиты, предусмотренным законодательством. Отказ от ответственности и ограничения, установленные для Правообладателя в данном соглашении, будут действовать и после его прекращения.\n\n')
		imgui.TextWrapped(u8'6.2 Правообладатель имеет право уведомить Вас и прекратить действие данного Соглашения относительно конкретной Программы или всех Программ в любое удобное время. После фактического прекращения действия Соглашения Вы теряете право на использование Программы.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'7. Основные положения ответственности сторон')
		imgui.PopFont()
		imgui.TextWrapped(u8'7.1 Правообладатель не несёт никакой ответственности в следующих случаях:\n\n7.1.1 Программа не работает должным образом в связи с нестабильным подключением интернета, устаревшими или неработоспособными техническими характеристиками устройства или Носителя, на которое установлена Программа, недостающим дополнительным ПО, которое обеспечивает необходимую работу Программы, либо из-за пользовательского редактирования программного кода Программы.\n\n7.1.2 Нарушение одного и более пунктов данного Соглашения, после установки Программы.\n\n')
		imgui.TextWrapped(u8'7.1.3 Утеря одной или нескольких копий Программы после её установки.\n\n7.1.4 Потеря трудоспособности Пользователя по любой причине, вследствие чего Пользователь не имеет более физической возможности использовать Программу.\n\n7.1.5 Пользователь согласился использовать Программу, прочитав Лицензионное соглашение, но в последствии, по собственной инициативе, решил отказаться от использования Программы.\n\n7.1.6 Пользователь не получает обновления Программы.\n\n7.1.7 Пользователь не имеет свободного места для установки Программы на Носитель.\n\n7.1.8 Пользователь не имеет возможности установить Программу в связи с отсутствием или нестабильным подключением Интернета.\n\n7.1.9 Пользователь не имеет возможности установить Программу в связи с ограничениями в стране или регионе, в котором он находится.\n\n7.1.10 Пользователь не имеет возможности установить Программу в связи с ПО, через которое он пытается совершить установку.\n\n')
		imgui.TextWrapped(u8'7.1.11 Пользователя не удовлетворили ожидания процесса работы Программы или его функциональные возможности.\n\n7.1.12 Пользователь погиб, либо получил физическую или моральную травму в результате пользования Программой.\n\n7.2 Пользователь несёт полную ответственность перед Правообладателем за соблюдение условий Соглашения.\n\n7.3 Программа предоставляется на международных условиях «как есть» (as is). Правообладатель не гарантирует безошибочную и бесперебойную работы Программы, её отдельных компонентов, функциональности, каким-либо целям и ожиданиям Пользователя, а также не предоставляет никаких иных гарантий, прямо не указанных в Соглашении.\n\n7.4 Правообладатель вправе изменить условия настоящего Соглашения в любой момент времени без предварительного уведомления Пользователя об этом.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'8. Общие положения')
		imgui.PopFont()
		imgui.TextWrapped(u8'8.1 Уведомления. В произвольное время Поставщик может направить Вам уведомление по электронной почте, через всплывающее окно, диалоговое окно или другие средства, даже если в некоторых случаях Вы можете не получить уведомление до тех пор, пока не запустите Программу. Такое уведомление считается доставленным с момента, когда Правообладатель сделал его доступным через Программу, независимо от фактического времени получения.\n\n8.2 Вопросы по данному Соглашению. Если у Вас возникнут вопросы относительно данного Соглашения или потребуется получить дополнительную информацию от Правообладателя, обратитесь по указанному ниже адресу электронной почты: morte4569@vk.com.\n\n')
		imgui.TextWrapped(u8'8.3 Импедимент выполнения обязательств. В случае каких-либо сбоев или снижения производительности, полностью или частично обусловленных непредвиденными ситуациями в предоставлении коммунальных услуг (включая электроэнергию), проблемами с подключением к интернету, недоступностью телекоммуникационных или информационно-технологических услуг, неисправностями телекоммуникационного или ИТ-оборудования, забастовками и другими подобными акциями, террористическими актами, DDoS-атаками и другими атаками и нарушениями ИТ-характера, стихийными бедствиями или обстоятельствами, которые находятся вне контроля Правообладателя, включая наводнения, саботаж, пожары, войны, спец. военные операции, нападения, теракты и прочие обстоятельства непреодолимой силы, а также любыми другими причинами, которые не поддаются существенному влиянию со стороны Правообладателя, Правообладатель освобождается от ответственности за такие события.\n\n')
		imgui.TextWrapped(u8'8.4 Передача прав и обязательств. Вам не разрешается передавать Ваши права или обязательства, установленные настоящим Соглашением, без предварительного письменного согласия Правообладателя. Своей стороной, Правообладатель вправе передать настоящее Соглашение в любой момент по своему усмотрению, без необходимости получения Вашего предварительного согласия в письменной форме.\n\n8.5 Подключение к Интернету. Для работы Программы необходимо обеспечить активное и стабильное подключение к Интернету. За обеспечение постоянного активного и стабильного Интернет-соединения отвечает лично Пользователь.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'9. Ответственности сторон при использовании Программы')
		imgui.PopFont()
		imgui.TextWrapped(u8'9.1 Программа обладает функцией обновления, осуществляемой путём загрузки файлов на тот же носитель, на котором установлена Программа.\n\n9.2 При установке и запуске Программы, Пользователь выражает своё согласие на получение неограниченного количества необходимых файлов для работы Программы с расширениями исполняемых файлов в форматах jpg, png, ttf, json, lua и txt в любой момент времени в процессе работы программы, а также на обработку файлов любого размера, не превышающего 8589934592 бит.\n\n9.3 Пользователь соглашается с тем, что Программа имеет право на неограниченное количество перезаписей и чтений установленных файлов в процессе её работы, без предварительного уведомления Пользователя Программы об этом.\n\n9.4 Пользователь принимает факт и соглашается с тем, что в любой момент времени по любой причине Программа или её файлы могут быть безвозвратно уничтожены в связи с сбоями Программы.\n\n')
		imgui.TextWrapped(u8'9.5 Правообладатель не несёт ответственности в случае сбоя операционной системы Пользователя (далее "ОС"), который может привести к временной или постоянной невозможности пользования ОС, а также к возможному уничтожению ОС с Носителя Пользователя в ходе выполнения Программы.\n\n9.6 Правообладатель не несёт ответственности за ошибки, допущенные Пользователем при использовании Программы, которые могут вызвать проблемы в ходе Игры, а также могут привести к ограничениям в использовании Игры, включая блокировку игрового аккаунта.\n\n9.7 Правообладатель осознаёт ответственность за намеренную кражу, попытку кражи, распространение, неправомерное использование личных данных пользователя с его технического Носителя. Правообладатель принимает на себя ответственность, при условии установки программы от официального лица в виде Правообладателя Программы, что Правообладатель понесёт ответственность согласно 273 ст. Уголовного Кодекса Российской Федерации (страна проживания Правообладателя) в случае распространения вредоносных программ на техническое устройство или технический Носитель Пользователя.\n')
		imgui.TextWrapped(u8'Правообладатель гарантирует отсутствие вредоносных файлов, вредоносных программ и модификаций в Программе и использующих ею файлов.\n\n9.8 Правообладатель вправе отправлять Пользователю уведомления любого типа, любого содержания, любой длительности отображения, в любой момент времени, в любом количестве и без предварительного информирования Пользователя об этом событии в самой Программе.\n\n9.9 Правообладатель наделил Программу возможностью в процессе её работы безвозвратно уничтожать, изменять содержимое или название файлов любого расширения, которые принадлежат Правообладателю или были созданы самой Программой в ходе её работы. Пользователь соглашается с этим решением.')
		imgui.EndChild()
		
		skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
		skin.Button(u8'Принять', 630, 400, nil, nil, function()
			first_start_anim.text[5] = false
			first_start_anim.text[6] = true
		end)
		skin.Button(u8'Назад', 515, 400, nil, nil, function()
			first_start_anim.text[4] = true
			first_start_anim.text[5] = false
		end)
		skin.EmphText(u8'Узнать подробнее', 140, 410, u8'Приняв пользовательское соглашение, Вы соглашаетесь\nс политикой данной программы.')
		imgui.PopFont()
	end
	
	if first_start_anim.text[6] then
		imgui.PushFont(font[1])
		
		skin.DrawFond({275, 242}, {-0.5, 0}, {24, 24}, imgui.ImVec4(0.35, 0.35, 0.35 ,1.00), 5, 15)
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
		imgui.PushFont(fa_font[1])
		imgui.SetCursorPos(imgui.ImVec2(279, 248))
		imgui.Text(fa.ICON_COG)
		imgui.PopFont()
		imgui.PopStyleColor(1)
		imgui.SetCursorPos(imgui.ImVec2(310, 246))
		if not type_version.rel then
			imgui.Text(u8'Всё отлично! У Вас последняя версия скрипта.')
		else
			imgui.Text(u8'Имеется обновление до версии '..new_version.version)
		end
		skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
		if not type_version.rel then
			skin.Button(u8'Завершить', 630, 400, nil, nil, function()
				first_start_anim.text[6] = false
				setting.int.first_start = false
				add_table_act(setting.frac.org, true)
				save('setting')
				create_act(1)
			end)
		else
			if not off_butoon_end then
				skin.Button(u8'Обновить', 630, 400, nil, nil, function()
					setting.int.first_start = false
					add_table_act(setting.frac.org, true)
					save('setting')
					update_download()
					off_butoon_end = true
				end)
			else
				skin.Button(u8'Обновить##false_non', 630, 400, nil, nil, function() end)
			end
		end
		skin.Button(u8'Назад', 515, 400, nil, nil, function()
			first_start_anim.text[5] = true
			first_start_anim.text[6] = false
		end)
		skin.EmphText(u8'Узнать подробнее', 140, 410, u8'Обновления нужны для устранения ошибок работы скрипта.\nДля корректной работы необходимо обновлять скрипт.')
		imgui.PopFont()
	end
	imgui.End()
end

local pos_el = {
	r_menu = 1,
	v_el = nil
}

function window.main()
	if pos_el.r_menu < 158 then
		pos_el.r_menu = (pos_el.r_menu * 0.9625) + 6
	else
		pos_el.r_menu = 158
	end
	local function button_menu(text_but_menu, pos_but_menu, imvec4_icon_but_menu, icon_but_menu, pos_icon_but_menu, arg_but_menu, par_plus_stoika, text_yk)
		local param_act_but = false
		if par_plus_stoika == nil then
			par_plus_stoika = {0, 0}
		end
		if text_yk == nil then
			text_yk = 0
		end
		imgui.SetCursorPos(imgui.ImVec2(pos_but_menu[1] + 4, pos_but_menu[2] + 4))
		local p = imgui.GetCursorScreenPos()
		if not arg_but_menu then
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
			if setting.int.theme == 'White' then
				imgui.PushStyleColor(imgui.Col.ButtonHovered,imgui.ImVec4(1.00, 1.00, 1.00, 0.60))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1.00, 1.00, 1.00, 0.80))
			else
				imgui.PushStyleColor(imgui.Col.ButtonHovered,imgui.ImVec4(1.00, 1.00, 1.00, 0.06))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1.00, 1.00, 1.00, 0.16))
			end
		end
		imgui.SetCursorPos(imgui.ImVec2(pos_but_menu[1] - 3, pos_but_menu[2] - 0.5))
		if imgui.Button(u8'##a2f'..text_but_menu, imgui.ImVec2(138, 33)) then param_act_but = true end
		imgui.PushFont(font[1])
		if arg_but_menu then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
		else
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.80))
		end
		imgui.SetCursorPos(imgui.ImVec2(pos_but_menu[1] + 36, pos_but_menu[2] + 8 + par_plus_stoika[2] + text_yk))
		imgui.Text(text_but_menu)
		imgui.PopStyleColor(1)
		imgui.PopFont()
		if not arg_but_menu then
			imgui.PopStyleColor(3)
		end
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + par_plus_stoika[1], p.y + par_plus_stoika[2]), imgui.ImVec2(p.x + 24, p.y + 24), imgui.GetColorU32(imvec4_icon_but_menu), 5, 15)
		imgui.PushFont(fa_font[4])
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
		imgui.SetCursorPos(imgui.ImVec2(pos_icon_but_menu[1] - 3, pos_icon_but_menu[2]))
		imgui.Text(icon_but_menu)
		imgui.PopStyleColor(1)
		imgui.PopFont()
		
		return param_act_but
	end
	imgui.SetNextWindowPos(imgui.ImVec2(interf.main.anim_win.x, interf.main.anim_win.y), interf.main.cond, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(interf.main.size.x, interf.main.size.y))
	imgui.Begin('Window Main', win.main.v, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + (size_win and imgui.WindowFlags.NoMove or 0))
	
	if interf.main.func or interf.main.anim_win.move then
		interf.main.cond = imgui.Cond.Always
	else
		interf.main.cond = imgui.Cond.FirstUseEver
	end
	if interf.main.func then
		interf.main.func = false
	end
	if not interf.main.collapse then
		skin.DrawFond({4, 4}, {0, 0}, {860, 460 + start_pos + new_pos}, imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00), 15, 15)
	end
	--> Левое меню
	if not interf.main.collapse then
		skin.DrawFond({4, 4}, {0, 0}, {pos_el.r_menu, 460 + start_pos + new_pos}, imgui.ImVec4(col_end.fond_one[1], col_end.fond_one[2], col_end.fond_one[3], 1.00), 15, 9)
	else
		skin.DrawFond({4, 4}, {0, 0}, {100, 50}, imgui.ImVec4(col_end.fond_one[1], col_end.fond_one[2], col_end.fond_one[3], 1.00), 15, 15)
	end
	
	imgui.SetCursorPos(imgui.ImVec2(4, 456 + start_pos + new_pos))
	if imgui.InvisibleButton(u8'##Границы', imgui.ImVec2(pos_el.r_menu, 12)) then end
	if imgui.IsItemHovered() or size_win then
		skin.DrawFond({4, 452 + start_pos + new_pos}, {0, 0}, {pos_el.r_menu, 12}, imgui.ImVec4(0.7, 0.7, 0.7, 1.00), 15, 8)
	end
	if imgui.IsItemClicked(0) then 
		new_pos_win_size = imgui.GetMousePos()
		size_win = true
		start_pos = interf.main.size.y - 469
		setting.start_pos = start_pos
		save('setting')
	end
	if imgui.IsMouseReleased(0) and size_win then 
		size_win = false
		setting.new_pos = new_pos
		setting.start_pos = start_pos
		save('setting')
	end
	
	if size_win then
		local gp = imgui.GetMousePos()
		new_pos = gp.y - new_pos_win_size.y
		local vert = 469 + start_pos + new_pos
		if vert > 469 then
			interf.main.size.y = 469 + start_pos + new_pos
		else
			start_pos = 0
			new_pos = 0
		end
	end
	
	--> Кнопки закрыть и свернуть
	imgui.SetCursorPos(imgui.ImVec2(13, 13))
	if imgui.InvisibleButton(u8'##Закрыть окно', imgui.ImVec2(20, 20)) or interf.main.anim_win.par  then
		pos_win_closed = imgui.GetWindowPos()
		styleAnimationClose('Main', interf.main.size.x, interf.main.size.y)
		interf.main.anim_win.par = false
	end
	imgui.SetCursorPos(imgui.ImVec2(23, 23))
	local p = imgui.GetCursorScreenPos()
	if imgui.IsItemHovered() then
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
		imgui.SetCursorPos(imgui.ImVec2(19, 16))
		imgui.PushFont(fa_font[2])
		imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
		imgui.PopFont()
	else
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
	end
	
	imgui.SetCursorPos(imgui.ImVec2(36, 13))
	if imgui.InvisibleButton(u8'##Свернуть окно', imgui.ImVec2(20, 20)) then
		
		if interf.main.collapse then
			interf.main.func = true
			interf.main.size.x = interf.main.size_def.x
			interf.main.size.y = interf.main.size_def.y + start_pos + new_pos
		else
			interf.main.func = true
			interf.main.size.x = 110
			interf.main.size.y = 60
		end
		interf.main.collapse = not interf.main.collapse
	end
	imgui.SetCursorPos(imgui.ImVec2(46, 23))
	local p = imgui.GetCursorScreenPos()
	if imgui.IsItemHovered() then
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.4, p.y - 0.3), 7, imgui.GetColorU32(imgui.ImVec4(0.35, 0.70, 0.30 ,1.00)), 60)
		imgui.SetCursorPos(imgui.ImVec2(43, 17))
		imgui.PushFont(fa_font[3])
		if not interf.main.collapse then
			imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.80), fa.ICON_COMPRESS)
		else
			imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.80), fa.ICON_EXPAND)
		end
		imgui.PopFont()
	else
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.4, p.y - 0.3), 7, imgui.GetColorU32(imgui.ImVec4(0.35, 0.80, 0.30 ,1.00)), 60)
	end
	imgui.GetCursorStartPos()
	if not interf.main.collapse then
		local function transition(num_trans)
			if select_main_menu[num_trans] then
				for i = 1, #select_main_menu do
					select_main_menu[i] = false
				end
			else
				for i = 1, #select_main_menu do
					if i ~= num_trans then
						select_main_menu[i] = false
					else
						select_main_menu[i] = true
					end
				end
			end
		end

		if button_menu(u8'Главное', {17, 50}, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_COG, {30, 57}, select_main_menu[1], {0.5, -0.5}, 0.0) then 
			transition(1)
		end
		if button_menu(u8'Команды', {17, 86}, imgui.ImVec4(0.97, 0.23, 0.19 ,1.00), fa.ICON_TERMINAL, {29, 93}, select_main_menu[2], nil, -0.5) then 
			sdvig_bool = false
			sdvig_num = 0
			sdvig = 0
			transition(2)
		end
		if button_menu(u8'Шпоры', {17, 122}, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00), fa.ICON_BOOK, {29, 129}, select_main_menu[3], nil, -1) then 
			transition(3)
			anim_menu_shpora[1] = 0
			anim_menu_shpora[3] = false
			anim_menu_shpora[4] = 0
		end
		if button_menu(u8'Департамент', {17, 158}, imgui.ImVec4(0.34, 0.33, 0.83 ,1.00), fa.ICON_SIGNAL, {29, 165}, select_main_menu[4], {0.5, -0.5}, -0.5) then
			if setting.depart.format == u8'[ЛСМЦ] - [ЛСПД]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '
			elseif setting.depart.format == u8'к ЛСПД,' then
				inp_text_dep = '/d '..u8'к'..' '..setting.depart.else_tag..', '
			elseif setting.depart.format == u8'[Больница ЛС] - [100,3] - [Полиция ЛС]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '
			end
			transition(4)
		end
		if button_menu(u8'Собес', {17, 194}, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00), fa.ICON_USER_PLUS, {28, 201}, select_main_menu[5], {0.5, -0.5}, -0.5) then 
			transition(5)
		end
		if button_menu(u8'Напоминания', {17, 230}, imgui.ImVec4(0.97, 0.27, 0.19 ,1.00), fa.ICON_BELL, {29, 237}, select_main_menu[6], {0.5, -0.5},  0.5) then 
			transition(6)
		end
		if button_menu(u8'Статистика', {17, 266}, imgui.ImVec4(0.20, 0.78, 0.35 ,1.00), fa.ICON_AREA_CHART, {28, 273}, select_main_menu[7], {0.5, -0.5}, 0.5) then 
			transition(7)
		end
		if button_menu(u8'Музыка', {17, 302}, imgui.ImVec4(1.00, 0.14, 0.33 ,1.00), fa.ICON_MUSIC, {29, 309}, select_main_menu[8], {-0.5, 0}, -0.5) then 
			transition(8)
			win.music.v = true
		end
		if button_menu(u8'РП зона', {17, 338}, imgui.ImVec4(0.15, 0.77, 0.38 ,1.00), fa.ICON_OBJECT_GROUP, {28, 345}, select_main_menu[9], nil, -0.5) then 
			transition(9)
		end
		if button_menu(u8'Лекционная', {17, 374}, imgui.ImVec4(0.75, 0.30, 1.00, 1.00), fa.ICON_MICROPHONE, {31, 382}, select_main_menu[11], nil, -1) then
			transition(11)
		end
		if button_menu(u8'О скрипте', {17, 410}, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_CODE, {28, 417}, select_main_menu[10], nil, -1) then
			transition(10)
		end
	end
	
	----> [0] Нулевое окно
	local all_false_sel_menu = true
	table.foreach(select_main_menu, function(k, v)
	  if v then
		all_false_sel_menu = false
		return
	  end
	end)

	if all_false_sel_menu then
		imgui.PushFont(bold_font[2])
		imgui.SetCursorPos(imgui.ImVec2(362, 198 + ((start_pos + new_pos) / 2)))
		imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,1.00), u8'State Helper')
		imgui.PopFont()
	end
	
	local all_false_sel_basic = true
	table.foreach(select_basic, function(k, v)
	  if v then
		all_false_sel_basic = false
		return
	  end
	end)
	
	local function menu_draw_up(text_m_d_up, meaning_f_t)
		local speed = 140
		local target_value = anim_menu_draw[2] and 203 or 177
		local currentTime = os.clock()
		local deltaTime = currentTime - lastTime
		lastTime = currentTime

		local target_value = anim_menu_draw[2] and 203 or 177

		if anim_menu_draw[1] < target_value then
			anim_menu_draw[1] = math.min(anim_menu_draw[1] + speed * deltaTime, target_value)
		elseif anim_menu_draw[1] > target_value then
			anim_menu_draw[1] = math.max(anim_menu_draw[1] - speed * deltaTime, target_value)
		end
		
		if setting.int.theme == 'White' then
			skin.DrawFond({162, 4}, {0, 0}, {702, 35}, imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00), 15, 2)
		else
			skin.DrawFond({162, 4}, {0, 0}, {702, 35}, imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00), 15, 2)
		end
		skin.DrawFond({162, 39}, {0, 0}, {702, 0.6}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
		
		imgui.PushFont(bold_font[1])
		if meaning_f_t == nil then
			imgui.SetCursorPos(imgui.ImVec2(anim_menu_draw[1], 8))
		else
			imgui.SetCursorPos(imgui.ImVec2(anim_menu_draw[1], 8))
		end
		imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text , 0.70), text_m_d_up)
		imgui.PopFont()
		
		if meaning_f_t ~= nil then
			anim_menu_draw[2] = true
			local pof_fsa = false
			imgui.PushFont(fa_font[6])
			imgui.SetCursorPos(imgui.ImVec2(176, 2))
			imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_ANGLE_LEFT)
			imgui.PopFont()
			imgui.SetCursorPos(imgui.ImVec2(171, 9))
			if imgui.InvisibleButton(u8'##4s2f'..text_m_d_up, imgui.ImVec2(26, 23)) then pof_fsa = true end
			return pof_fsa
		else
			anim_menu_draw[2] = false
		end
	end
	
	if status_track_pl == 'STOP' then
		imgui.SetCursorPos(imgui.ImVec2(70, 9))
		imgui.Image(IMG_Premium, imgui.ImVec2(75, 27))
	else
		imgui.SetCursorPos(imgui.ImVec2(66, 23))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 4, p.y + level_potok / 2), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
		imgui.SetCursorPos(imgui.ImVec2(66, 23))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 4, p.y - level_potok / 2), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
		
		imgui.SetCursorPos(imgui.ImVec2(73, 23))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 4, p.y + audio_vizual / 2), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
		imgui.SetCursorPos(imgui.ImVec2(73, 23))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 4, p.y - audio_vizual / 2), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
		
		imgui.SetCursorPos(imgui.ImVec2(80, 23)) 
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 4, p.y + frequency / 2), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
		imgui.SetCursorPos(imgui.ImVec2(80, 23))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 4, p.y - frequency / 2), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
		
	end
		
	----> [1] Главное
	if select_main_menu[1] and all_false_sel_basic then
		menu_draw_up(u8'Главное')
		
		imgui.SetCursorPos(imgui.ImVec2(180, 41))
		imgui.BeginChild(u8'Главное', imgui.ImVec2(666, 423 + start_pos + new_pos), false, imgui.WindowFlags.NoScrollbar + (size_win and imgui.WindowFlags.NoMove or 0))
		local function drawn_button(y_p_b, flag_d_b, text_d_b, pl_text_d_b)
			if pl_text_d_b == nil then
				pl_text_d_b = 0
			end
			local par_b_d = false
			imgui.SetCursorPos(imgui.ImVec2(0, y_p_b))
			local p = imgui.GetCursorScreenPos()

			imgui.SetCursorPos(imgui.ImVec2(0, y_p_b))
			if imgui.InvisibleButton(u8'##fd3'..y_p_b, imgui.ImVec2(666, 40)) then par_b_d = true end
			if imgui.IsItemActive() then
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 40), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, flag_d_b)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 40), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, flag_d_b)
				end
			else
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 40), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, flag_d_b)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 40), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, flag_d_b)
				end
			end
			imgui.PushFont(fa_font[5])
			imgui.SetCursorPos(imgui.ImVec2(637, y_p_b + 6))
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
			imgui.Text(fa.ICON_ANGLE_RIGHT)
			imgui.PopStyleColor(1)
			imgui.PopFont()
			
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(50, y_p_b + 11 + pl_text_d_b))
			imgui.Text(text_d_b)
			imgui.PopFont()
			
			return par_b_d
		end
		local function drawn_icon_b(y_p_i, imvec4_i, icon_i, pos_i, deviation_i)
			if deviation_i == nil then
				deviation_i = {0, 0}
			end
			imgui.SetCursorPos(imgui.ImVec2(15, y_p_i + 5))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + deviation_i[1], p.y + deviation_i[2]), imgui.ImVec2(p.x + 24, p.y + 24), imgui.GetColorU32(imvec4_i), 5, 15)
			
			if pos_i ~= nil then
			imgui.PushFont(fa_font[4])
			imgui.SetCursorPos(imgui.ImVec2(pos_i[1] - 5, pos_i[2]))
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
			imgui.Text(icon_i)
			imgui.PopStyleColor(1)
			imgui.PopFont()
			end
			
		end
		if drawn_button(17, 3, u8'Личная информация') then select_basic = {true, false, false, false, false, false, false, false, false, false} end
		drawn_icon_b(19, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_LOCK, {27, 28}, {-0.3, 0})
		
		if drawn_button(57, 0, u8'Настройки чата') then select_basic = {false, true, false, false, false, false, false, false, false, false} end
		drawn_icon_b(60, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00), fa.ICON_BARS, {26, 68}, {0.5, -0.5})
		
		if drawn_button(97, 0, u8'Ценовая политика') then select_basic = {false, false, true, false, false, false, false, false, false, false} end
		drawn_icon_b(100, imgui.ImVec4(0.20, 0.78, 0.35 ,1.00), fa.ICON_USD, {28, 108})
		
		if drawn_button(137, 12, u8'Акцент', 1) then select_basic = {false, false, false, true, false, false, false, false, false, false} end
		drawn_icon_b(141, imgui.ImVec4(0.97, 0.23, 0.19 ,1.00), fa.ICON_COMMENTING, {25, 148})
		
		skin.DrawFond({51, 57}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		skin.DrawFond({51, 97}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		skin.DrawFond({51, 137}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		
		if drawn_button(187, 3, u8'Мемберс') then select_basic = {false, false, false, false, true, false, false, false, false, false} end
		drawn_icon_b(189, imgui.ImVec4(0.0, 0.47, 0.99 ,1.00), fa.ICON_USER_CIRCLE_O, {25, 197}, {-0.4, 0.7})
		
		if drawn_button(227, 0, u8'Уведомления') then select_basic = {false, false, false, false, false, true, false, false, false, false} end
		drawn_icon_b(230, imgui.ImVec4(0.34, 0.33, 0.83 ,1.00), fa.ICON_PAPER_PLANE, {24, 238})
		
		if drawn_button(267, 0, u8'Быстрый доступ') then select_basic = {false, false, false, false, false, false, true, false, false, false} end
		drawn_icon_b(270, imgui.ImVec4(1.0, 0.14, 0.33 ,1.00), fa.ICON_LINK, {25, 278})
		
		if drawn_button(307, 0, u8'Дополнительные функции') then select_basic = {false, false, false, false, false, false, false, true, false, false} end
		drawn_icon_b(310, imgui.ImVec4(0.22, 0.82, 0.55, 1.00), fa.ICON_TOGGLE_ON, {24, 318})
		
		if drawn_button(347, 12, u8'Настройки скрипта', 1) then select_basic = {false, false, false, false, false, false, false, false, true, false} end
		drawn_icon_b(351, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_SLIDERS, {26, 359}, {0, 0.5})
		
		skin.DrawFond({51, 227}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		skin.DrawFond({51, 267}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		skin.DrawFond({51, 307}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		skin.DrawFond({51, 347}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		
		if drawn_button(397, 15, u8'Обновления', 1) then select_basic = {false, false, false, false, false, false, false, false, false, true} end
		drawn_icon_b(400, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_DOWNLOAD,  {25, 409})
		
		imgui.Dummy(imgui.ImVec2(0, 20)) 
		
		imgui.EndChild()
	elseif select_main_menu[1] and not all_false_sel_basic then
		local function new_draw(pos_draw, par_dr_y)
			imgui.SetCursorPos(imgui.ImVec2(17, pos_draw))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
		end
		if select_basic[1] then
			if menu_draw_up(u8'Личная информация', true) then select_basic[1] = false end
			imgui.SetCursorPos(imgui.ImVec2(163, 41))
			imgui.BeginChild(u8'Личная информация', imgui.ImVec2(700, 422 + start_pos + new_pos), false, imgui.WindowFlags.NoScrollbar + (size_win and imgui.WindowFlags.NoMove or 0))
			
			new_draw(17, 76)
			skin.InputText(33, 36, u8'Ваш ник на русском языке',' setting.nick', 74, 633, '[а-Я%s]+', 'setting')
			imgui.SetCursorPos(imgui.ImVec2(34, 65))
			imgui.PushFont(font[3])
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Ваш ник на русском языке будет полезен для использования в различных отыгровках.')
			imgui.PopFont()
			
			new_draw(105, 82)
			imgui.SetCursorPos(imgui.ImVec2(34, 148))
			imgui.PushFont(font[3])
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'От выбранной организации, в которой Вы состоите, зависит доступность различ-')
			imgui.SetCursorPos(imgui.ImVec2(34, 162))
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'ных функций и команд. Скрипт поддерживает только организации из списка.')
			imgui.PopFont()
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 122))
			imgui.Text(u8'Организация')
			imgui.PopFont()
			if skin.List({480, 116}, setting.frac.org, {u8'Больница ЛС', u8'Больница ЛВ', u8'Больница СФ', u8'Больница Джефферсон', u8'Центр Лицензирования', u8'Центральный Банк'}, 185, 'setting.frac.org') then 
				add_table_act(setting.frac.org, false)
				save('setting')
				create_act(1)
			end
			
			new_draw(199, 65)
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 216))
			imgui.Text(u8'Должность')
			local calc = imgui.CalcTextSize(setting.frac.title)
			imgui.SetCursorPos(imgui.ImVec2(660 - calc.x, 216))
			imgui.Text(setting.frac.title)
			imgui.PopFont()
			imgui.SetCursorPos(imgui.ImVec2(34, 238))
			imgui.PushFont(font[3])
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Определено автоматически.')
			imgui.PopFont()
			
			new_draw(276, 65)
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 293))
			imgui.Text(u8'Пол')
			imgui.PopFont()
			imgui.SetCursorPos(imgui.ImVec2(34, 315))
			imgui.PushFont(font[3])
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Необходимо для отыгровок.')
			imgui.PopFont()
			if skin.List({480, 287}, setting.sex, {u8'Мужской', u8'Женский'}, 185, 'setting.sex') then save('setting') end
			
			new_draw(353, 76)
			skin.InputText(33, 372, u8'Тег в рацию организации','setting.teg', 74, 633, '[а-Я%s]+', 'setting')
			imgui.PushFont(font[3])
			imgui.SetCursorPos(imgui.ImVec2(34, 401))
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'О необходимости использования тега, уточните у лидера организации.')
			imgui.PopFont()
			
			imgui.Dummy(imgui.ImVec2(0, 25))
			imgui.EndChild()
		elseif select_basic[2] then
			if menu_draw_up(u8'Настройки чата', true) then select_basic[2] = false end
			imgui.SetCursorPos(imgui.ImVec2(163, 41))
			imgui.BeginChild(u8'Настройки чата', imgui.ImVec2(700, 422 + start_pos + new_pos), false, imgui.WindowFlags.NoScrollbar + (size_win and imgui.WindowFlags.NoMove or 0))
			
			new_draw(17, 107)
			imgui.SetCursorPos(imgui.ImVec2(639, 30))
			if skin.Switch(u8'##Объявления от игроков', setting.chat_pl) then setting.chat_pl = not setting.chat_pl save('setting') end
			imgui.SetCursorPos(imgui.ImVec2(639, 60))
			if skin.Switch(u8'##репортажи новости СМИ', setting.chat_smi) then setting.chat_smi = not setting.chat_smi save('setting') end
			imgui.SetCursorPos(imgui.ImVec2(639, 90))
			if skin.Switch(u8'##частые подсказки сервера', setting.chat_help) then setting.chat_help = not setting.chat_help save('setting') end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 31))
			imgui.Text(u8'Скрыть объявления от игроков в СМИ')
			imgui.SetCursorPos(imgui.ImVec2(34, 61))
			imgui.Text(u8'Скрыть репортажи и новости от СМИ')
			imgui.SetCursorPos(imgui.ImVec2(34, 91))
			imgui.Text(u8'Скрыть частые подсказки сервера')
			imgui.PopFont()
			
			new_draw(136, 47)
			imgui.SetCursorPos(imgui.ImVec2(639, 149))
			if skin.Switch(u8'##Дата и время снизу', setting.time_hud) then setting.time_hud = not setting.time_hud save('setting') end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 150))
			imgui.Text(u8'Отображать дату и время под миникартой')
			imgui.PopFont()
			
			new_draw(195, 143)
			skin.InputText(33, 214, u8'Текст отыгровки времени /time', 'setting.act_time', 128, 633, nil, 'setting')
			imgui.SetCursorPos(imgui.ImVec2(34, 243))
			imgui.PushFont(font[3])
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Отыгровка после ввода /time. Оставьте пустым, если не нужно.')
			imgui.PopFont()
			skin.InputText(33, 280, u8'Текст отыгровки рации /r', 'setting.act_r', 128, 633, nil, 'setting')
			imgui.SetCursorPos(imgui.ImVec2(34, 309))
			imgui.PushFont(font[3])
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Отыгровка после ввода /r. Оставьте пустым, если не нужно.')
			imgui.PopFont()
			
			new_draw(350, 47)
			imgui.SetCursorPos(imgui.ImVec2(639, 363))
			if skin.Switch(u8'##Автоскрин /time', setting.ts) then setting.ts = not setting.ts save('setting') end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 364))
			imgui.Text(u8'/time + скриншот экрана командой /ts')
			imgui.PopFont()
			
			new_draw(409, 47)
			imgui.SetCursorPos(imgui.ImVec2(639, 422))
			if skin.Switch(u8'##Отыгровка палки резиновой', setting.rubber_stick) then setting.rubber_stick = not setting.rubber_stick save('setting') end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 423))
			imgui.Text(u8'Отыгровка дубинки')
			imgui.PopFont()
			
			imgui.Dummy(imgui.ImVec2(0, 27))
			imgui.EndChild()
		elseif select_basic[3] then
			if menu_draw_up(u8'Ценовая политика', true) then select_basic[3] = false end
			imgui.SetCursorPos(imgui.ImVec2(163, 41))
			imgui.BeginChild(u8'Ценовая политика', imgui.ImVec2(700, 422 + start_pos + new_pos), false, imgui.WindowFlags.NoScrollbar + (size_win and imgui.WindowFlags.NoMove or 0))
			
			if setting.frac.org == u8'Центр Лицензирования' or setting.frac.org == u8'Центральный Банк' then
				imgui.PushFont(bold_font[4])
				imgui.SetCursorPos(imgui.ImVec2(92, 187 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'Для Вас нет ценовой политики')
				imgui.PopFont()
			else
				new_draw(17, 140)
				imgui.PushFont(font[1])
				skin.InputText(105, 36, u8'Лечение', 'setting.price.lec', 10, 200, 'num', 'setting')
				skin.InputText(105, 76, u8'Рецепт', 'setting.price.rec', 10, 200, 'num', 'setting')
				skin.InputText(105, 116, u8'Татуировка', 'setting.price.tatu', 10, 200, 'num', 'setting')
				skin.InputText(465, 36, u8'Антибиотик', 'setting.price.ant', 10, 200, 'num', 'setting')
				skin.InputText(465, 76, u8'Наркозависимость', 'setting.price.narko', 10, 200, 'num', 'setting')
				skin.InputText(465, 116, u8'Медицинский осмотр', 'setting.priceosm', 10, 200, 'num', 'setting')
				
				new_draw(169, 182)
				skin.InputText(163, 188, u8'Мед. карта 7 дней', 'setting.price.mede.1', 10, 140, 'num', 'setting')
				skin.InputText(163, 228, u8'Мед. карта 14 дней', 'setting.price.mede.2', 10, 140, 'num', 'setting')
				skin.InputText(163, 268, u8'Мед. карта 30 дней', 'setting.price.mede.3', 10, 140, 'num', 'setting')
				skin.InputText(163, 308, u8'Мед. карта 60 дней', 'setting.price.mede.4', 10, 140, 'num', 'setting')
				skin.InputText(524, 188, u8'Новая 7 дней', 'setting.price.upmede.1', 10, 140, 'num', 'setting')
				skin.InputText(524, 228, u8'Новая 14 дней', 'setting.price.upmede.2', 10, 140, 'num', 'setting')
				skin.InputText(524, 268, u8'Новая 30 дней', 'setting.price.upmede.3', 10, 140, 'num', 'setting')
				skin.InputText(524, 308, u8'Новая 60 дней', 'setting.price.upmede.4', 10, 140, 'num', 'setting')
				
				imgui.SetCursorPos(imgui.ImVec2(34, 37))
				imgui.Text(u8'Лечение')
				imgui.SetCursorPos(imgui.ImVec2(34, 77))
				imgui.Text(u8'Рецепт')
				imgui.SetCursorPos(imgui.ImVec2(34, 117))
				imgui.Text(u8'Тату')
				imgui.SetCursorPos(imgui.ImVec2(380, 37))
				imgui.Text(u8'Антибиотик')
				imgui.SetCursorPos(imgui.ImVec2(380, 77))
				imgui.Text(u8'Наркозав.')
				imgui.SetCursorPos(imgui.ImVec2(380, 117))
				imgui.Text(u8'Мед. осмотр')
				imgui.SetCursorPos(imgui.ImVec2(34, 189))
				imgui.Text(u8'Мед. карта 7 дней')
				imgui.SetCursorPos(imgui.ImVec2(34, 229))
				imgui.Text(u8'Мед. карта 14 дней')
				imgui.SetCursorPos(imgui.ImVec2(34, 269))
				imgui.Text(u8'Мед. карта 30 дней')
				imgui.SetCursorPos(imgui.ImVec2(34, 309))
				imgui.Text(u8'Мед. карта 60 дней')
				imgui.SetCursorPos(imgui.ImVec2(353, 189))
				imgui.Text(u8'Мед. карта новая 7 дней')
				imgui.SetCursorPos(imgui.ImVec2(353, 229))
				imgui.Text(u8'Мед. карта новая 14 дней')
				imgui.SetCursorPos(imgui.ImVec2(353, 269))
				imgui.Text(u8'Мед. карта новая 30 дней')
				imgui.SetCursorPos(imgui.ImVec2(353, 309))
				imgui.Text(u8'Мед. карта новая 60 дней')
				imgui.PopFont()
			end

			imgui.EndChild()
		elseif select_basic[4] then
			if menu_draw_up(u8'Акцент', true) then select_basic[4] = false end
			imgui.SetCursorPos(imgui.ImVec2(163, 41))
			imgui.BeginChild(u8'Акцент', imgui.ImVec2(700, 422 + start_pos + new_pos), false, imgui.WindowFlags.NoScrollbar + (size_win and imgui.WindowFlags.NoMove or 0))
			
			new_draw(17, 47)
			imgui.SetCursorPos(imgui.ImVec2(639, 30))
			if skin.Switch(u8'##Использовать акцент', setting.accent.func) then setting.accent.func = not setting.accent.func save('setting') end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 31))
			imgui.Text(u8'Использовать акцент')
			imgui.PopFont()
			
			if setting.accent.func then
				new_draw(76, 76)
				skin.InputText(33, 95, u8'Введите Ваш собственный акцент', 'setting.accent.text', 128, 633, '[а-Я%s]+', 'setting')
				imgui.SetCursorPos(imgui.ImVec2(34, 124))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Начните с заглавной буквы. Слово "акцент" писать не нужно. Например, "Британский".')
				imgui.PopFont()
				
				new_draw(164, 137)
				imgui.SetCursorPos(imgui.ImVec2(639, 177))
				if skin.Switch(u8'##Акцент в рацию', setting.accent.r) then setting.accent.r = not setting.accent.r save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 207))
				if skin.Switch(u8'##Акцент при крике', setting.accent.s) then setting.accent.s = not setting.accent.s save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 237))
				if skin.Switch(u8'##Акцент в рацию депа', setting.accent.d) then 
					setting.accent.d = not setting.accent.d 
					save('setting')
					if setting.accent.d and not setting.dep_off then
						sampRegisterChatCommand('d', function(text_accents_d) 
							if text_accents_d ~= '' and setting.accent.func and setting.accent.d and setting.accent.text ~= '' then
								sampSendChat('/d ['..u8:decode(setting.accent.text)..' акцент]: '..text_accents_d)
							else
								sampSendChat('/d '..text_accents_d)
							end 
						end)
					elseif not setting.accent.d and not setting.dep_off then
						sampUnregisterChatCommand('d')
					end
				end
				imgui.SetCursorPos(imgui.ImVec2(639, 267))
				if skin.Switch(u8'##Акцент в рацию банды', setting.accent.f) then setting.accent.f = not setting.accent.f save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 178))
				imgui.Text(u8'Акцент в рацию организации (/r)')
				imgui.SetCursorPos(imgui.ImVec2(34, 208))
				imgui.Text(u8'Акцент во время крика (/s)')
				imgui.SetCursorPos(imgui.ImVec2(34, 238))
				imgui.Text(u8'Акцент в рацию департамента (/d)')
				imgui.SetCursorPos(imgui.ImVec2(34, 268))
				imgui.Text(u8'Акцент в чат банды/мафии (/f)')
				
				imgui.PopFont()
			end
			imgui.EndChild()
		elseif select_basic[5] then
			if menu_draw_up(u8'Мемберс', true) then select_basic[5] = false end
			imgui.SetCursorPos(imgui.ImVec2(163, 41))
			imgui.BeginChild(u8'Мемберс', imgui.ImVec2(700, 422 + start_pos + new_pos), false, imgui.WindowFlags.NoScrollbar + (size_win and imgui.WindowFlags.NoMove or 0))
			
			new_draw(17, 47)
			imgui.SetCursorPos(imgui.ImVec2(639, 30))
			if skin.Switch(u8'##Мемберс на экране', setting.members.func) then setting.members.func = not setting.members.func save('setting') end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 31))
			imgui.Text(u8'Мемберс организации на Вашем экране')
			imgui.PopFont()
			
			if setting.members.func then
				new_draw(76, 77)
				imgui.SetCursorPos(imgui.ImVec2(639, 89))
				if skin.Switch(u8'##Скрывать при диалоге', setting.members.dialog) then setting.members.dialog = not setting.members.dialog save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 119))
				if skin.Switch(u8'##Инверсировать текст', setting.members.invers) then setting.members.invers = not setting.members.invers save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 90))
				imgui.Text(u8'Скрывать текст, если открыт диалог')
				imgui.SetCursorPos(imgui.ImVec2(34, 120))
				imgui.Text(u8'Инверсировать текст')
				
				new_draw(165, 166)
				imgui.SetCursorPos(imgui.ImVec2(639, 178))
				if skin.Switch(u8'##Выделять цветом в форме', setting.members.form) then setting.members.form = not setting.members.form save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 208))
				if skin.Switch(u8'##Отображать id', setting.members.id) then setting.members.id = not setting.members.id save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 238))
				if skin.Switch(u8'##Отображать ранг', setting.members.rank) then setting.members.rank = not setting.members.rank save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 268))
				if skin.Switch(u8'##Отображать afk', setting.members.afk) then setting.members.afk = not setting.members.afk save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 298))
				if skin.Switch(u8'##Отображать выговоры', setting.members.warn) then setting.members.warn = not setting.members.warn save('setting') end
				
				imgui.SetCursorPos(imgui.ImVec2(34, 179))
				imgui.Text(u8'Выделять цветом тех, кто в форме')
				imgui.SetCursorPos(imgui.ImVec2(34, 209))
				imgui.Text(u8'Отображать id игроков')
				imgui.SetCursorPos(imgui.ImVec2(34, 239))
				imgui.Text(u8'Отображать ранг игроков')
				imgui.SetCursorPos(imgui.ImVec2(34, 269))
				imgui.Text(u8'Отображать время АФК')
				imgui.SetCursorPos(imgui.ImVec2(34, 299))
				imgui.Text(u8'Отображать количество выговоров')
				
				imgui.PopFont()
				
				new_draw(343, 138)
				if skin.Slider('##Размер шрифта', 'setting.members.size', 1, 25, 205, {470, 357}, 'setting') then fontes = renderCreateFont('Trebuchet MS', setting.members.size, setting.members.flag) save('setting') end
				if skin.Slider('##Флаг шрифта', 'setting.members.flag', 1, 25, 205, {470, 384}, 'setting') then fontes = renderCreateFont('Trebuchet MS', setting.members.size, setting.members.flag) save('setting') end
				skin.Slider('##Расстояние между строками', 'setting.members.dist', 1, 30, 205, {470, 414}, 'setting')
				skin.Slider('##Прозрачность текста', 'setting.members.vis', 1, 255, 205, {470, 444}, 'setting')
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 356))
				imgui.Text(u8'Размер шрифта')
				imgui.SetCursorPos(imgui.ImVec2(34, 386))
				imgui.Text(u8'Флаг шрифта')
				imgui.SetCursorPos(imgui.ImVec2(34, 416))
				imgui.Text(u8'Расстояние между строками')
				imgui.SetCursorPos(imgui.ImVec2(34, 446))
				imgui.Text(u8'Прозрачность текста')
				
				new_draw(493, 48)
				imgui.SetCursorPos(imgui.ImVec2(34, 506))
				if imgui.ColorEdit4('##TitleColor', col.title, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
					local c = imgui.ImVec4(col.title.v[1], col.title.v[2], col.title.v[3], col.title.v[4])
					local argb = imgui.ColorConvertFloat4ToARGB(c)
					setting.members.color.title = imgui.ColorConvertFloat4ToARGB(c)
					save('setting')
				end
				imgui.SetCursorPos(imgui.ImVec2(306, 506))
				if imgui.ColorEdit4('##WorkColor', col.work, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
					local c = imgui.ImVec4(col.work.v[1], col.work.v[2], col.work.v[3], col.work.v[4])
					local argb = imgui.ColorConvertFloat4ToARGB(c)
					setting.members.color.work = imgui.ColorConvertFloat4ToARGB(c)
					save('setting')
				end
				imgui.SetCursorPos(imgui.ImVec2(569, 506))
				if imgui.ColorEdit4('##DefaultColor', col.default, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
					local c = imgui.ImVec4(col.default.v[1], col.default.v[2], col.default.v[3], col.default.v[4])
					local argb = imgui.ColorConvertFloat4ToARGB(c)
					setting.members.color.default = imgui.ColorConvertFloat4ToARGB(c)
					save('setting')
				end
				
				imgui.SetCursorPos(imgui.ImVec2(61, 508))
				imgui.Text(u8'Заголовок')
				imgui.SetCursorPos(imgui.ImVec2(333, 508))
				imgui.Text(u8'В форме')
				imgui.SetCursorPos(imgui.ImVec2(596, 508))
				imgui.Text(u8'Без формы')
				
				
				new_draw(553, 63)
				skin.Button(u8'Изменить положение текста', 34, 567, 633, nil, function() 
					changePosition()
				end)
				imgui.PopFont()
				imgui.Dummy(imgui.ImVec2(0, 35))
			end
			imgui.EndChild()
		elseif select_basic[6] then
			if menu_draw_up(u8'Уведомления', true) then select_basic[6] = false end
			imgui.SetCursorPos(imgui.ImVec2(163, 41))
			imgui.BeginChild(u8'Уведомления', imgui.ImVec2(700, 422 + start_pos + new_pos), false, imgui.WindowFlags.NoScrollbar + (size_win and imgui.WindowFlags.NoMove or 0))
			
			new_draw(17, 68)
			imgui.SetCursorPos(imgui.ImVec2(639, 30))
			if skin.Switch(u8'##Уведомлять о спавне авто', setting.notice.car) then setting.notice.car = not setting.notice.car save('setting') end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 31))
			imgui.Text(u8'Уведомлять звуковым сигналом о спавне авто')
			imgui.PopFont()
			imgui.SetCursorPos(imgui.ImVec2(34, 53))
			imgui.PushFont(font[3])
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Когда администрация предупредит о спавне авто, Вы будете уведомлены звуковым сигналом.')
			imgui.PopFont()
			
			if not setting.notice.dep then
				new_draw(97, 68)
			else
				new_draw(97, 158)
			end
			imgui.SetCursorPos(imgui.ImVec2(639, 110))
			if skin.Switch(u8'##Уведомлять о вызове организации в рации департамента', setting.notice.dep) then setting.notice.dep = not setting.notice.dep save('setting') end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 111))
			imgui.Text(u8'Уведомлять о вызове организации в рации департамента')
			imgui.PopFont()
			imgui.SetCursorPos(imgui.ImVec2(34, 133))
			imgui.PushFont(font[3])
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Когда в рации департамента обратятся к Вашей организации, Вы будете уведомлены звуком.')
			imgui.PopFont()
			if setting.notice.dep then
				skin.InputText(175, 168, u8'Тег Вашей организации', 'setting.dep.my_tag', 128, 490, '^[a-zA-Z ]+$', 'setting')
				skin.InputText(175, 210, u8'Дополнительный тег, например, на английском', 'setting.dep.my_tag_en', 128, 490, '^[a-zA-Z ]+$', 'setting')
				
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 169))
				imgui.Text(u8'Тег организации')
				imgui.SetCursorPos(imgui.ImVec2(34, 211))
				imgui.Text(u8'Дополнительный тег')
				imgui.PopFont()
			end
			
			imgui.EndChild()
		elseif select_basic[7] then
			if menu_draw_up(u8'Быстрый доступ', true) then select_basic[7] = false end
			imgui.SetCursorPos(imgui.ImVec2(163, 41))
			imgui.BeginChild(u8'Быстрый доступ', imgui.ImVec2(700, 422 + start_pos + new_pos), false, imgui.WindowFlags.NoScrollbar + (size_win and imgui.WindowFlags.NoMove or 0))
			
			new_draw(17, 47)
			imgui.SetCursorPos(imgui.ImVec2(639, 30))
			if skin.Switch(u8'##Быстрый доступ', setting.fast_acc.func) then setting.fast_acc.func = not setting.fast_acc.func save('setting') end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 31))
			imgui.Text(u8'Быстрый доступ с игроками (ПКМ + R)')
			
			imgui.PopFont()
			if setting.fast_acc.func then
				local bk_size = 176
				if #setting.fast_acc.sl ~= 0 then
					local table_remove_acc = 0
					for i = 1, #setting.fast_acc.sl do
						new_draw(76 + ((i - 1) * bk_size), bk_size - 12)
						imgui.SetCursorPos(imgui.ImVec2(636, 134 + ((i - 1) * bk_size)))
						if imgui.InvisibleButton('##Удалить действие'..i, imgui.ImVec2(40, 40)) then table_remove_acc = i end
						imgui.PushFont(fa_font[1])
						imgui.SetCursorPos(imgui.ImVec2(649, 148 + ((i - 1) * bk_size)))
						imgui.Text(fa.ICON_TRASH)
						imgui.PopFont()
						
						imgui.PushFont(font[1])
						imgui.SetCursorPos(imgui.ImVec2(34, 92 + ((i - 1) * bk_size)))
						imgui.Text(u8'Имя действия')
						skin.InputText(134, 90 + ((i - 1) * bk_size), u8'Задайте имя действия##'..i, 'setting.fast_acc.sl.'..i..'.text', 80, 495, nil, 'setting')
						imgui.SetCursorPos(imgui.ImVec2(34, 132 + ((i - 1) * bk_size)))
						imgui.Text(u8'Команда')
						skin.InputText(134, 130 + ((i - 1) * bk_size), u8'Введи исполняемую команду##'..i, 'setting.fast_acc.sl.'..i..'.cmd', 16, 495, '[%a%d+-]+', 'setting')
						
						imgui.SetCursorPos(imgui.ImVec2(34,  175 + ((i - 1) * bk_size)))
						imgui.Text(u8'Передавать в первый аргумент id игрока')
						imgui.SetCursorPos(imgui.ImVec2(34,  205 + ((i - 1) * bk_size)))
						imgui.Text(u8'Отправлять команду без подтверждения')
						imgui.SetCursorPos(imgui.ImVec2(600,  174 + ((i - 1) * bk_size)))
						if skin.Switch(u8'##Передавать в первый аргумент id игрока'..i, setting.fast_acc.sl[i].pass_arg) then
							setting.fast_acc.sl[i].pass_arg = not setting.fast_acc.sl[i].pass_arg
							save('setting') 
						end
						imgui.SetCursorPos(imgui.ImVec2(600,  204 + ((i - 1) * bk_size)))
						if skin.Switch(u8'##Отправлять команду без подтверждения'..i, setting.fast_acc.sl[i].send_chat) then
							setting.fast_acc.sl[i].send_chat = not setting.fast_acc.sl[i].send_chat
							save('setting')
						end
						imgui.PopFont()
					end
					if table_remove_acc ~= 0 then table.remove(setting.fast_acc.sl, table_remove_acc) save('setting') end
				end
				
				imgui.PushFont(font[1])
				skin.Button(u8'Добавить действие', 250, 88 + (#setting.fast_acc.sl * bk_size), 200, 35, function()
					if setting.cmd ~= 0 then
						local new_cell_table = {
							text = u8'Действие '..#setting.fast_acc.sl,
							cmd = setting.cmd[1][1],
							pass_arg = true,
							send_chat = true
						}
						table.insert(setting.fast_acc.sl, new_cell_table)
						save('setting')
					end
				end)
				imgui.PopFont()
			end
			imgui.Dummy(imgui.ImVec2(0, 20))
			imgui.EndChild()
		elseif select_basic[8] then
			if menu_draw_up(u8'Дополнительные функции', true) then select_basic[8] = false end
			imgui.SetCursorPos(imgui.ImVec2(163, 41))
			imgui.BeginChild(u8'Дополнительные функции', imgui.ImVec2(700, 422 + start_pos + new_pos), false, imgui.WindowFlags.NoScrollbar + (size_win and imgui.WindowFlags.NoMove or 0))
			
			new_draw(17, 68)
			imgui.SetCursorPos(imgui.ImVec2(639, 30))
			if skin.Switch(u8'##Скоростное открытие двери', setting.speed_door) then
				setting.speed_door = not setting.speed_door save('setting')
				if setting.speed_door then
					rkeys.registerHotKey({72}, 1, true, function() on_hot_key({72}) end)
				else
					rkeys.unRegisterHotKey({72})
				end
			end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 31))
			imgui.Text(u8'Скоростное открытие дверей и шлагбаумов')
			imgui.PopFont()
			imgui.SetCursorPos(imgui.ImVec2(34, 53))
			imgui.PushFont(font[3])
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Двери и шлагбаумы станут открываться моментально на клавишу H.')
			imgui.PopFont()
			
			new_draw(97, 81)
			imgui.SetCursorPos(imgui.ImVec2(639, 110))
			if skin.Switch(u8'##Отключить рацию департамента', setting.dep_off) then
				setting.dep_off = not setting.dep_off 
				save('setting')
				if setting.dep_off then
					sampRegisterChatCommand('d', function()
						sampAddChatMessage(script_tag..'{FFFFFF}Вы отключили команду /d в настройках.', color_tag)
					end)
				else
					sampUnregisterChatCommand('d')
				end
			end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 111))
			imgui.Text(u8'Отключить команду рации департамента (/d)')
			imgui.PopFont()
			imgui.PushFont(font[3])
			imgui.SetCursorPos(imgui.ImVec2(34, 133))
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Если Вы очень часто по случайности отправляете информацию в рацию департамента, то можете отклю-')
			imgui.SetCursorPos(imgui.ImVec2(34, 147))
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'чить команду /d. Тогда эта команда просто перестанет работать.')
			imgui.PopFont()
			
			new_draw(190, 68)
			imgui.SetCursorPos(imgui.ImVec2(639, 203))
			if skin.Switch(u8'##Автопринятие документов', setting.show_dialog_auto) then
				setting.show_dialog_auto = not setting.show_dialog_auto save('setting')
			end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 204))
			imgui.Text(u8'Автоматическое принятие документов')
			imgui.PopFont()
			imgui.SetCursorPos(imgui.ImVec2(34, 226))
			imgui.PushFont(font[3])
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'/offer будет приниматься автоматически.')
			imgui.PopFont()
			
			imgui.EndChild()
		elseif select_basic[9] then
			if menu_draw_up(u8'Настройки скрипта', true) then select_basic[9] = false end
			imgui.SetCursorPos(imgui.ImVec2(163, 41))
			imgui.BeginChild(u8'Настройки скрипта', imgui.ImVec2(700, 422 + start_pos + new_pos), false, imgui.WindowFlags.NoScrollbar + (size_win and imgui.WindowFlags.NoMove or 0))
			
			new_draw(17, 225)
			if buf_setting.theme[1].v then
				skin.DrawFond({64, 39}, {- 1.0,- 0.8}, {203, 112}, imgui.ImVec4(0.26, 0.50, 0.94, 1.00), 15, 15)
			end
			if buf_setting.theme[2].v then
				skin.DrawFond({434, 39}, {- 1.0, - 0.8}, {203, 112}, imgui.ImVec4(0.26, 0.50, 0.94, 1.00), 15, 15)
			end
			skin.DrawFond({65, 40}, {0, 0}, {200, 109}, imgui.ImVec4(1.00, 1.00, 1.00, 1.00), 15, 15)
			skin.DrawFond({65, 40}, {0, 0}, {40, 109}, imgui.ImVec4(0.91, 0.89, 0.76, 0.80), 15, 9)
			
			skin.DrawFond({70, 55}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
			skin.DrawFond({70, 78}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
			skin.DrawFond({70, 101}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
			skin.DrawFond({70, 125}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
			skin.DrawFond({165, 55}, {0, 0}, {40, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
			skin.DrawFond({115, 78}, {0, 0}, {130, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
			skin.DrawFond({115, 101}, {0, 0}, {70, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
			skin.DrawFond({115, 125}, {0, 0}, {110, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
			
			skin.DrawFond({435, 40}, {0, 0}, {200, 109}, imgui.ImVec4(0.08, 0.08, 0.08, 1.00), 15, 15)
			skin.DrawFond({435, 40}, {0, 0}, {40, 109}, imgui.ImVec4(0.15, 0.13, 0.13, 0.70), 15, 9)
			
			skin.DrawFond({440, 55}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
			skin.DrawFond({440, 78}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
			skin.DrawFond({440, 101}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
			skin.DrawFond({440, 125}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
			skin.DrawFond({535, 55}, {0, 0}, {40, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
			skin.DrawFond({485, 78}, {0, 0}, {130, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
			skin.DrawFond({485, 101}, {0, 0}, {70, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
			skin.DrawFond({485, 125}, {0, 0}, {110, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
			
			if not buf_setting.theme[1].v then
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
				imgui.PushStyleColor(imgui.Col.FrameBgHovered,imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
				imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0.40, 0.40, 0.40, 1.00))
			else
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
				imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
				imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00))
			end
			
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(98, 170))
			imgui.Text(u8'Светлое оформление')

			if buf_setting.theme[1].v then
				if skin.CheckboxOne(u8'##whitebox', 160, 200) then
					
				end
			else
				if skin.CheckboxOne(u8'##whitebox##false_func', 160, 200) then
					buf_setting.theme[1].v = true
					buf_setting.theme[2].v = false
					setting.int.theme = 'White'
					save('setting')
				end
			end
			imgui.PopStyleColor(3)
			if not buf_setting.theme[2].v then
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
				imgui.PushStyleColor(imgui.Col.FrameBgHovered,imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
				imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0.40, 0.40, 0.40, 1.00))
			else
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
				imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
				imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00))
			end

			imgui.SetCursorPos(imgui.ImVec2(470, 170))
			imgui.Text(u8'Тёмное оформление')
			if buf_setting.theme[2].v then
				if skin.CheckboxOne(u8'##blackebox', 530, 200) then
					
				end
			else
				if skin.CheckboxOne(u8'##blackbox##false_func', 530, 200) then
					buf_setting.theme[1].v = false
					buf_setting.theme[2].v = true
					setting.int.theme = 'Black'
					save('setting')
				end
			end
			imgui.PopStyleColor(3)
			imgui.PopFont()
			
			new_draw(254, 47)
			local function accent_col(num_acc, color_acc, color_acc_act)
				imgui.SetCursorPos(imgui.ImVec2(354 + (num_acc * 43), 277))
				local p = imgui.GetCursorScreenPos()
				
				imgui.SetCursorPos(imgui.ImVec2(343 + (num_acc * 43), 266))
				if imgui.InvisibleButton(u8'##Выбрать акцент'..num_acc, imgui.ImVec2(22, 22)) then
					setting.col_acc_non = color_acc
					setting.col_acc_act = color_acc_act
					setting.color_accent_num = num_acc
					save('setting')
					style_window()
				end
				if imgui.IsItemActive() then
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 11, imgui.GetColorU32(imgui.ImVec4(color_acc_act[1], color_acc_act[2], color_acc_act[3] ,1.00)), 60)
				else
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 11, imgui.GetColorU32(imgui.ImVec4(color_acc[1], color_acc[2], color_acc[3] ,1.00)), 60)
				end
				if num_acc == setting.color_accent_num then
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 4, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 60)
				end
			end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 268))
			imgui.Text(u8'Цветовой акцент')
			accent_col(1, {0.26, 0.45, 0.94}, {0.26, 0.35, 0.94})
			accent_col(2, {0.75, 0.35, 0.87}, {0.75, 0.25, 0.87})
			accent_col(3, {1.00, 0.22, 0.37}, {1.00, 0.12, 0.37})
			accent_col(4, {1.00, 0.27, 0.23}, {1.00, 0.17, 0.23})
			accent_col(5, {1.00, 0.57, 0.04}, {1.00, 0.47, 0.04})
			accent_col(6, {0.20, 0.74, 0.29}, {0.20, 0.64, 0.29})
			accent_col(7, {0.50, 0.50, 0.52}, {0.40, 0.40, 0.42})
			imgui.PopFont()
			
			new_draw(313, 47)
			imgui.SetCursorPos(imgui.ImVec2(639, 326))
			if skin.Switch(u8'##Отключить анимацию открытия и закрытия окна', setting.anim_main) then setting.anim_main = not setting.anim_main save('setting') end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 327))
			imgui.Text(u8'Отключить анимацию движения окон')
			imgui.PopFont()
			
			imgui.EndChild()
		elseif select_basic[10] then
			if menu_draw_up(u8'Обновления', true) then select_basic[10] = false end
			imgui.SetCursorPos(imgui.ImVec2(163, 41))
			imgui.BeginChild(u8'Обновления', imgui.ImVec2(700, 422 + start_pos + new_pos), false, imgui.WindowFlags.NoScrollbar + (size_win and imgui.WindowFlags.NoMove or 0))
			new_draw(17, 68)
			imgui.SetCursorPos(imgui.ImVec2(639, 30))
			if skin.Switch(u8'##Автообновление', setting.auto_update) then
				setting.auto_update = not setting.auto_update 
				save('setting')
			end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(34, 31))
			imgui.Text(u8'Автоматическое обновление')
			imgui.SetCursorPos(imgui.ImVec2(34, 53))
			imgui.PushFont(font[3])
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Скрипт будет обновляться автоматически, без Вашего подтверждения.')
			imgui.PopFont()
			if upd_status == 0 then
				new_draw(97, 85)
				imgui.SetCursorPos(imgui.ImVec2(34, 109))
				imgui.Text(u8'Обновлений нет. Установлена актуальная версия скрипта.')
				skin.Button(u8'Проверить наличие обновления', 32, 137, 636, 27, function() update_check() end)
			elseif upd_status == 1 then
				new_draw(97, 43)
				imgui.SetCursorPos(imgui.ImVec2(34, 109))
				imgui.Text(u8'Проверка наличия обновлений...')
			elseif upd_status == 2 then
				new_draw(97, 308)
				imgui.SetCursorPos(imgui.ImVec2(30, 110))
				imgui.Image(IMG_New_Version, imgui.ImVec2(60, 60))
				
				imgui.PushFont(font[4])
				imgui.SetCursorPos(imgui.ImVec2(107, 127))
				imgui.Text(u8'State Helper Premium '..upd.version)
				imgui.PopFont()
				
				imgui.SetCursorPos(imgui.ImVec2(32, 185))
				imgui.BeginChild(u8'Инфо обновления', imgui.ImVec2(636, 180), false)
				imgui.TextWrapped(u8(upd.text)..'\n\n'..u8(upd.info))
				imgui.EndChild()
				
				if not update_box then
					skin.Button(u8'Обновить', 32, 365, 636, 27, function() 
						update_download()
						update_box = true
					end)
				else
					skin.Button(u8'Обновление запрошено...##false_non', 32, 365, 636, 27, function() end)
				end
			end
			imgui.PopFont()
			imgui.EndChild()
		end
		
	----> [2] Команды
	elseif select_main_menu[2] and select_cmd == 0 then
		local function new_draw(pos_draw, par_dr_y)
			imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
		end
		menu_draw_up(u8'Команды')
		
		imgui.PushFont(fa_font[1])
		imgui.SetCursorPos(imgui.ImVec2(826, 11))
		imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 4)
		if imgui.Button(u8'##Добавить команду', imgui.ImVec2(22, 22)) then
			local comp = 1
			local num_el = {}
			if #setting.cmd ~= 0 then
				for _, element in ipairs(setting.cmd) do
					if string.match(element[1], '^cmd%d+$') then
						table.insert(num_el, tonumber(string.match(element[1], '^cmd(%d+)$')))
					end
				end
			end
			if num_el ~= 0 then
				table.sort(num_el)
				for i = 1, #num_el do
					if num_el[i] ~= comp then
						break
					else
						comp = comp + 1
					end
				end
			end
			table.insert(setting.cmd, {'cmd'..comp, '', {}, '1'})
			save('setting')
			cmd = {
				nm = 'cmd'..comp,
				desc = u8'',
				delay = 2000,
				key = {},
				arg = {},
				var = {},
				act = {},
				num_d = 1,
				tr_fl = {0, 0, 0},
				add_f = {false, 1},
				not_send_chat = false,
				rank = '1'
			}
			local f = io.open(dirml..'/StateHelper/Отыгровки/cmd'..comp..'.json', 'w')
			f:write(encodeJson(cmd))
			f:flush()
			f:close()
			select_cmd = #setting.cmd
			anim_menu_cmd = {130, os.clock(), 0.00}
			sampRegisterChatCommand('cmd'..comp, function(arg) cmd_start(arg, 'cmd'..comp) end)
			sdvig_bool = false
			sdvig_num = 0
			sdvig = 0
		end
		imgui.PopStyleVar(1)
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(255, 255, 255, 255):GetVec4())
		imgui.SetCursorPos(imgui.ImVec2(830, 17))
		imgui.Text(fa.ICON_PLUS)
		imgui.PopStyleColor(1)
		imgui.PopFont()
		
		local speed = 710
		local target_value = sdvig_bool and 120 or 0
		local currentTime = os.clock()
		local deltaTime = currentTime - time_os_shp
		time_os_shp = currentTime

		local target_value = sdvig_bool and 120 or 0

		if sdvig < target_value then
			sdvig = math.min(sdvig + speed * deltaTime, target_value)
		elseif sdvig > target_value then
			sdvig = math.max(sdvig - speed * deltaTime, target_value)
		end
		
		if not sdvig_bool then
			if sdvig == 0 then sdvig_num = 0 end
		end
		
		imgui.SetCursorPos(imgui.ImVec2(180, 41))
		imgui.BeginChild(u8'Команды', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
		if #setting.cmd == 0 then
			imgui.PushFont(bold_font[4])
			imgui.SetCursorPos(imgui.ImVec2(141, 187 + ((start_pos + new_pos) / 2)))
			imgui.Text(u8'Нет ни одной команды')
			imgui.PopFont()
		else
			if sdvig == 0 then
				new_draw(17, -1 + (#setting.cmd * 68))
			else
				imgui.SetCursorPos(imgui.ImVec2(0, 17))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + -1 + (#setting.cmd * 68)), imgui.GetColorU32(imgui.ImVec4(0.70, 0.70, 0.70, 1.00)), 8, 15)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + -1 + (#setting.cmd * 68)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 8, 15)
				end
			end
			imgui.PushFont(font[1])
			local remove_cmd
			for i = 1, #setting.cmd do
				imgui.SetCursorPos(imgui.ImVec2(0 - sdvig, 17 + ( (i - 1) * 68)))
				if imgui.InvisibleButton(u8'##Перейти в редактор отыгровки'..i, imgui.ImVec2(666, 68)) then 
					sdvig_bool = not sdvig_bool
					if sdvig_num == 0 then
						sdvig_num = i
					end
				end
				imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemActive() and sdvig == 0 then
					if i == 1 and #setting.cmd ~= 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 3)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 3)
						end
					elseif i == 1 and #setting.cmd == 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 15)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 15)
						end 
					elseif i == #setting.cmd then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 12)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 12)
						end
					else
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 0)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 0)
						end
					end
				end
				imgui.PushFont(fa_font[5])
				if sdvig_num ~= i and sdvig == 0 then
					imgui.SetCursorPos(imgui.ImVec2(640, 37 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
					imgui.Text(fa.ICON_ANGLE_RIGHT)
					imgui.PopStyleColor(1)
					imgui.PopFont()
					imgui.SetCursorPos(imgui.ImVec2(17, 31 + ( (i - 1) * 68)))
					imgui.Text('/'..setting.cmd[i][1])
					imgui.SetCursorPos(imgui.ImVec2(17, 51 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.60))
					if setting.cmd[i][2]:gsub('%s','') == '' then
						imgui.Text(u8'Без описания')
					else
						imgui.Text(setting.cmd[i][2])
					end
					imgui.PopStyleColor(1)
				elseif sdvig_num ~= i and sdvig ~= 0 then
					imgui.SetCursorPos(imgui.ImVec2(640, 37 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.20))
					imgui.Text(fa.ICON_ANGLE_RIGHT)
					imgui.PopStyleColor(1)
					imgui.PopFont()
					imgui.SetCursorPos(imgui.ImVec2(17, 31 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.20))
					imgui.Text('/'..setting.cmd[i][1])
					imgui.PopStyleColor(1)
					imgui.SetCursorPos(imgui.ImVec2(17, 51 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.10))
					if setting.cmd[i][2]:gsub('%s','') == '' then
						imgui.Text(u8'Без описания')
					else
						imgui.Text(setting.cmd[i][2])
					end
					imgui.PopStyleColor(1)
				end
				
				if sdvig_num == i then
					imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
					local p = imgui.GetCursorScreenPos()
					if i == 1 and #setting.cmd ~= 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 18)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 18)
						end
					elseif i == 1 and #setting.cmd == 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 22)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 22)
						end 
					elseif i == #setting.cmd then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 20)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 20)
						end
					else
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 0)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 0)
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
					if imgui.InvisibleButton(u8'##Удалить команду', imgui.ImVec2(60, 68)) then
						remove_cmd = i
						sdvig_bool = false
						sdvig_num = 0
						sdvig = 0
					end
					
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
						local p = imgui.GetCursorScreenPos()
						if i == 1 and #setting.cmd ~= 1 then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 18)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 18)
							end
						elseif i == 1 and #setting.cmd == 1 then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 22)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 22)
							end 
						elseif i == #setting.cmd then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 20)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 20)
							end
						else
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 0)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 0)
							end
						end
					end
					
					imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
					local p = imgui.GetCursorScreenPos()
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.57, 0.04, 1.00)))
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.57, 0.04, 1.00)))
					end
					imgui.SetCursorPos(imgui.ImVec2(626, 38 + ( (i - 1) * 68)))
					imgui.PushFont(fa_font[5])
					imgui.Text(fa.ICON_TRASH)
					imgui.SetCursorPos(imgui.ImVec2(566, 38 + ( (i - 1) * 68)))
					imgui.Text(fa.ICON_PENCIL)
					imgui.PopFont()
					imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
					local p = imgui.GetCursorScreenPos()
					if i == 1 and #setting.cmd ~= 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 1)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 1)
						end
					elseif i == 1 and #setting.cmd == 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 9)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 9)
						end 
					elseif i == #setting.cmd then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 8)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 8)
						end
					else
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 0)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 0)
						end
					end
					
					imgui.SetCursorPos(imgui.ImVec2(640 - sdvig, 37 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
					imgui.Text(fa.ICON_ANGLE_RIGHT)
					imgui.PopStyleColor(1)
					imgui.PopFont()
					imgui.SetCursorPos(imgui.ImVec2(17 - sdvig, 31 + ( (i - 1) * 68)))
					imgui.Text('/'..setting.cmd[i][1])
					imgui.SetCursorPos(imgui.ImVec2(17 - sdvig, 51 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.60))
					if setting.cmd[i][2]:gsub('%s','') == '' then
						imgui.Text(u8'Без описания')
					else
						imgui.Text(setting.cmd[i][2])
					end
					imgui.PopStyleColor(1)
					imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
					if imgui.InvisibleButton(u8'##Открыть команду', imgui.ImVec2(60, 68)) then
						sdvig_bool = false
						sdvig_num = 0
						sdvig = 0
						
						POS_Y = 380
						if doesFileExist(dirml..'/StateHelper/Отыгровки/'..setting.cmd[i][1]..'.json') then
							local f = io.open(dirml..'/StateHelper/Отыгровки/'..setting.cmd[i][1]..'.json')
							local setm = f:read('*a')
							f:close()
							local res, set = pcall(decodeJson, setm)
							if res and type(set) == 'table' then 
								cmd = set
							end
							select_cmd = i
							anim_menu_cmd = {130, os.clock(), 0.00}
						else
							remove_cmd = i
						end
					end
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
						local p = imgui.GetCursorScreenPos()
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.47, 0.04, 1.00)))
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.47, 0.04, 1.00)))
						end
						imgui.PushFont(fa_font[5])
						imgui.SetCursorPos(imgui.ImVec2(566, 38 + ( (i - 1) * 68)))
						imgui.Text(fa.ICON_PENCIL)
						imgui.PopFont()
					end
				end
			end
			if remove_cmd ~= nil then
				if doesFileExist(dirml..'/StateHelper/Отыгровки/'..setting.cmd[remove_cmd][1]..'.json') then
					os.remove(dirml..'/StateHelper/Отыгровки/'..setting.cmd[remove_cmd][1]..'.json')
				end
				sampUnregisterChatCommand(setting.cmd[remove_cmd][1])
				if #setting.cmd[remove_cmd][3] ~= 0 then
					rkeys.unRegisterHotKey(setting.cmd[remove_cmd][3])
				end
				table.remove(setting.cmd, remove_cmd) 
				save('setting')
				
			end
			if #setting.cmd > 1 then
				for draw = 1, #setting.cmd - 1 do
					if sdvig == 0 then
						skin.DrawFond({17, 16 + (draw * 68)}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
					else
						skin.DrawFond({17, 16 + (draw * 68)}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.20), 0, 0)
					end
				end
			end
			imgui.PopFont()
		end
		imgui.Dummy(imgui.ImVec2(0, 80))
		imgui.EndChild()
	elseif select_main_menu[2] and select_cmd ~= 0 then
		local function new_draw(pos_draw, par_dr_y, sizes_if_win, comm_tr)
			if sizes_if_win == nil then
				sizes_if_win = {17, 666}
			end
			imgui.SetCursorPos(imgui.ImVec2(sizes_if_win[1], pos_draw))
			local p = imgui.GetCursorScreenPos()
			if comm_tr == nil then
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
				end
			else
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(0.99, 1.00, 0.21, 0.50)), 8, 15)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(0.99, 1.00, 0.21, 0.30)), 8, 15)
				end
			end
		end
		
		if menu_draw_up(u8'Редактирование команды', true) then
			imgui.OpenPopup(u8'Дальнейшие действия с командой')
			command_err_nm = false
			command_err_cmd = false
		end
		if imgui.BeginPopupModal(u8'Дальнейшие действия с командой', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.BeginChild(u8'Действие с командой', imgui.ImVec2(400, 200), false, imgui.WindowFlags.NoScrollbar)
			imgui.SetCursorPos(imgui.ImVec2(0, 0))
			if imgui.InvisibleButton(u8'##Закрыть окошко команд', imgui.ImVec2(20, 20)) then
				imgui.CloseCurrentPopup()
			end
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			local p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
				imgui.SetCursorPos(imgui.ImVec2(6, 3))
				imgui.PushFont(fa_font[2])
				imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
			end
			
			imgui.PushFont(bold_font[4])
			if not command_err_nm and not command_err_cmd then
				imgui.SetCursorPos(imgui.ImVec2(35, 55))
				imgui.Text(u8'Выберите действие')
			elseif not command_err_cmd then
				imgui.SetCursorPos(imgui.ImVec2(127, 39))
				imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'ОШИБКА')
				
				imgui.PushFont(font[4])
				imgui.SetCursorPos(imgui.ImVec2(63, 95))
				imgui.Text(u8'Такая команда уже существует!')
				imgui.PopFont()
			elseif command_err_cmd then
				imgui.SetCursorPos(imgui.ImVec2(127, 39))
				imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'ОШИБКА')
				
				imgui.PushFont(font[4])
				imgui.SetCursorPos(imgui.ImVec2(126, 95))
				imgui.Text(u8'Задайте команду!')
				imgui.PopFont()
			end
			imgui.PopFont()
			imgui.PushFont(font[1])
			skin.Button(u8'Сохранить', 10, 167, 123, 25, function()
				if cmd.nm == 'sh' or cmd.nm == 'ts' then command_err_nm = true end
				for i = 1, #setting.cmd do
					if setting.cmd[i][1] == cmd.nm and i ~= select_cmd then
						command_err_nm = true
						break
					end
				end
				if cmd.nm == '' then
					command_err_cmd = true
				end
				if not command_err_nm and not command_err_cmd then
					if doesFileExist(dirml..'/StateHelper/Отыгровки/'..setting.cmd[select_cmd][1]..'.json') then
						os.remove(dirml..'/StateHelper/Отыгровки/'..setting.cmd[select_cmd][1]..'.json')
					end
					local f = io.open(dirml..'/StateHelper/Отыгровки/'..cmd.nm..'.json', 'w')
					f:write(encodeJson(cmd))
					f:flush()
					f:close()
					if setting.cmd[select_cmd][1] ~= cmd.nm then
						sampUnregisterChatCommand(setting.cmd[select_cmd][1])
						sampRegisterChatCommand(cmd.nm, function(arg) cmd_start(arg, cmd.nm) end)
					end
					if #setting.cmd[select_cmd][3] ~= 0 then
						rkeys.unRegisterHotKey(setting.cmd[select_cmd][3])
					end
					if #cmd.key ~= 0 then
						rkeys.registerHotKey(cmd.key, 3, true, function() on_hot_key(cmd.key) end)
					end
					setting.cmd[select_cmd] = {cmd.nm, cmd.desc, cmd.key, cmd.rank}
					save('setting')
					select_cmd = 0
					imgui.CloseCurrentPopup()
				end
			end)
			skin.Button(u8'Не сохранять', 138, 167, 124, 25, function()
				select_cmd = 0
				imgui.CloseCurrentPopup()
			end)
			skin.Button(u8'Удалить', 267, 167, 123, 25, function()
				if doesFileExist(dirml..'/StateHelper/Отыгровки/'..setting.cmd[select_cmd][1]..'.json') then
					os.remove(dirml..'/StateHelper/Отыгровки/'..setting.cmd[select_cmd][1]..'.json')
				end
				sampUnregisterChatCommand(setting.cmd[select_cmd][1])
				if #setting.cmd[select_cmd][3] ~= 0 then
					rkeys.unRegisterHotKey(setting.cmd[select_cmd][3])
				end
				table.remove(setting.cmd, select_cmd)
				save('setting')
				select_cmd = 0
				imgui.CloseCurrentPopup()
			end)
			imgui.PopFont()
			imgui.EndChild()
			imgui.EndPopup()
		end
		
		if select_cmd ~= 0 then
			local function dr_circuit_mini(y_pos_plus, icon_circ, imvec4_ic)
				local return_bool = false
				
				local pos_icon = {4, 0}
				local text_add_func = ''
				if icon_circ == fa.ICON_SHARE then
					text_add_func = u8'Отправить в чат'
				elseif icon_circ == fa.ICON_HOURGLASS then
					pos_icon = {6, -1}
					text_add_func = u8'Ожидание нажатия клавиши Enter'
				elseif icon_circ == fa.ICON_LIST then
					pos_icon = {4, -1}
					text_add_func = u8'Вывести информацию в чат (для себя)'
				elseif icon_circ == fa.ICON_PENCIL then
					pos_icon = {6, -1}
					text_add_func = u8'Изменить значение переменной'
				elseif icon_circ == fa.ICON_ALIGN_LEFT then
					text_add_func = u8'Комментарий'
				elseif icon_circ == fa.ICON_LIST_OL then
					pos_icon = {4, -1}
					text_add_func = u8'Диалог выбора дальнейшего действия'
				elseif icon_circ == fa.ICON_SIGN_OUT then
					pos_icon = {5, -1}
					text_add_func = u8'Если выбран вариант диалога...'
				elseif icon_circ == fa.ICON_STOP..'2' then
					pos_icon = {6, -1}
					text_add_func = u8'Завершить диалог'
				elseif icon_circ == fa.ICON_SUPERSCRIPT then
					pos_icon = {6, -1}
					text_add_func = u8'Если переменная равна...'
				elseif icon_circ == fa.ICON_STOP..'1' then
					pos_icon = {6, -1}
					text_add_func = u8'Завершить условие переменной'
				end
				
				imgui.SetCursorPos(imgui.ImVec2(100, POS_Y_CMD_F + y_pos_plus))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 500, p.y + 34), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 8, 15)
				imgui.SetCursorPos(imgui.ImVec2(100, POS_Y_CMD_F + y_pos_plus))
				if imgui.InvisibleButton(u8'##Добавить функцию в редакторе'..POS_Y_CMD_F + y_pos_plus..icon_circ, imgui.ImVec2(500, 34)) then return_bool = true end
				if imgui.IsItemActive() then
					imgui.SetCursorPos(imgui.ImVec2(101, POS_Y_CMD_F + y_pos_plus + 1))
					local p = imgui.GetCursorScreenPos()
					
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 498, p.y + 32), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 498, p.y + 32), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
					end
				end
				
				imgui.SetCursorPos(imgui.ImVec2(105, POS_Y_CMD_F + y_pos_plus + 5))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 24, p.y + 24), imgui.GetColorU32(imvec4_ic), 5, 15)
				
				imgui.PushFont(fa_font[4])
				imgui.SetCursorPos(imgui.ImVec2(580, POS_Y_CMD_F + y_pos_plus + 9))
				imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_PLUS)
				imgui.SetCursorPos(imgui.ImVec2(105 + pos_icon[1], POS_Y_CMD_F + y_pos_plus + 9 + pos_icon[2]))
				imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), icon_circ)
				imgui.PopFont()
				
				imgui.SetCursorPos(imgui.ImVec2(140, POS_Y_CMD_F + y_pos_plus + 8))
				imgui.Text(text_add_func)
				
				return return_bool
			end
			
			if active_child_cmd then
				if pos_Y_cmd < 150 then
					pos_Y_cmd = pos_Y_cmd + 10
				else
					pos_Y_cmd = 150
				end
			else
				if pos_Y_cmd > 35 then
					pos_Y_cmd = pos_Y_cmd - 10
				else
					pos_Y_cmd = 35
				end
			end
			imgui.SetCursorPos(imgui.ImVec2(162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos))
			if imgui.InvisibleButton(u8'##Посмотреть варианты сл действия', imgui.ImVec2(702, 35)) then
				active_child_cmd = not active_child_cmd
			end
			if imgui.IsItemActive() then
				if setting.int.theme == 'White' then
					skin.DrawFond({162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos}, {0, 0}, {702, pos_Y_cmd}, imgui.ImVec4(col_end.fond_two[1] - 0.03, col_end.fond_two[2] - 0.03, col_end.fond_two[3] - 0.03, 1.00), 15, 20)
				else
					skin.DrawFond({162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos}, {0, 0}, {702, pos_Y_cmd}, imgui.ImVec4(col_end.fond_two[1] + 0.02, col_end.fond_two[2] + 0.02, col_end.fond_two[3] + 0.02, 1.00), 15, 20)
				end
			elseif imgui.IsItemHovered() then
				if setting.int.theme == 'White' then
					skin.DrawFond({162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos}, {0, 0}, {702, pos_Y_cmd}, imgui.ImVec4(col_end.fond_two[1] - 0.01, col_end.fond_two[2] + 0.01, col_end.fond_two[3] + 0.01, 1.00), 15, 20)
				else
					skin.DrawFond({162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos}, {0, 0}, {702, pos_Y_cmd}, imgui.ImVec4(col_end.fond_two[1] + 0.08, col_end.fond_two[2] + 0.08, col_end.fond_two[3] + 0.08, 1.00), 15, 20)
				end
			else
				if setting.int.theme == 'White' then
					skin.DrawFond({162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos}, {0, 0}, {702, pos_Y_cmd}, imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00), 15, 20)
				else
					skin.DrawFond({162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos}, {0, 0}, {702, pos_Y_cmd}, imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00), 15, 20)
				end
			end
			skin.DrawFond({162, 428 - (pos_Y_cmd - 35) + start_pos + new_pos}, {-0.5, 0}, {702, 0.6}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
			imgui.PushFont(font[4])
			imgui.SetCursorPos(imgui.ImVec2(360, 434 - (pos_Y_cmd - 35) + start_pos + new_pos))
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), u8'Варианты следующего действия')
			imgui.PopFont()
			imgui.PushFont(fa_font[5])
			imgui.SetCursorPos(imgui.ImVec2(650, 433 - (pos_Y_cmd - 35) + start_pos + new_pos))
			if active_child_cmd then
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), fa.ICON_ANGLE_DOWN)
			else
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), fa.ICON_ANGLE_UP)
			end
			imgui.PopFont()
			imgui.PushFont(font[1])
			if active_child_cmd then
				skin.DrawFond({162, 462 - (pos_Y_cmd - 35) + start_pos + new_pos}, {-0.5, 0}, {702, 1.6}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
				imgui.SetCursorPos(imgui.ImVec2(163, 464 - (pos_Y_cmd - 35) + start_pos + new_pos))
				imgui.BeginChild(u8'Функции действия', imgui.ImVec2(700, pos_Y_cmd - 35), false)
				local num_a = #cmd.act + 1
				if cmd.add_f[1] and #cmd.act ~= 0 then
					num_a = cmd.add_f[2] + 1
				end
				
				if dr_circuit_mini(50, fa.ICON_SHARE, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {0, u8''}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {0, u8''})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
				end
				if dr_circuit_mini(90, fa.ICON_HOURGLASS, imgui.ImVec4(0.13, 0.83, 0.24 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {1, u8''}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {1, u8''})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
				end
				if dr_circuit_mini(130, fa.ICON_LIST, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {2, u8''}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {2, u8''})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
				end
				if dr_circuit_mini(170, fa.ICON_LIST_OL, imgui.ImVec4(0.88, 0.18, 0.20 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {3, cmd.num_d, 2, {u8'Действие 1', u8'Действие 2'}}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {3, cmd.num_d, 2, {u8'Действие 1', u8'Действие 2'}})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
					cmd.num_d = cmd.num_d + 1
					cmd.tr_fl[2] = cmd.tr_fl[2] + 1
				end
				if dr_circuit_mini(210, fa.ICON_ALIGN_LEFT, imgui.ImVec4(0.88, 0.81, 0.18 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {4, u8''}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {4, u8''})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
				end
				local res_pos = 250
				if #cmd.var ~= 0 then
					if dr_circuit_mini(res_pos, fa.ICON_PENCIL, imgui.ImVec4(0.83, 0.13, 0.41 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {5, '{var1}', u8''}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {5, '{var1}', u8''})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
					end
					res_pos = res_pos + 40
					if dr_circuit_mini(res_pos, fa.ICON_SUPERSCRIPT, imgui.ImVec4(1.00, 0.21, 0.41 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {6, '{var1}', ''}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {6, '{var1}', ''})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
						cmd.tr_fl[1] = cmd.tr_fl[1] + 1
					end
					res_pos = res_pos + 40
				end
				
				if cmd.tr_fl[1] ~= 0 then
					if dr_circuit_mini(res_pos, fa.ICON_STOP..'1', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {7, '{var1}'}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {7, ''})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
					end
					res_pos = res_pos + 40
				end
				if cmd.tr_fl[2] ~= 0 then
					if dr_circuit_mini(res_pos, fa.ICON_SIGN_OUT, imgui.ImVec4(1.00, 0.21, 0.41 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {8, '1', '1'}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {8, '1', '1'})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
						cmd.tr_fl[3] = cmd.tr_fl[3] + 1
					end
					res_pos = res_pos + 40
				end
				if cmd.tr_fl[2] ~= 0 and cmd.tr_fl[3] ~= 0 then
					if dr_circuit_mini(res_pos, fa.ICON_STOP..'2', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {9, '1', '1'}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {9, ''})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
					end
					res_pos = res_pos + 40
			end
				imgui.EndChild()
			end
			imgui.PopFont()
			
			local speed = (anim_menu_cmd[1] - 39) * 5.8
			local currentTime = os.clock()
			local deltaTime = currentTime - anim_menu_cmd[2]
			anim_menu_cmd[2] = currentTime

			local anim_duration = math.abs(anim_menu_cmd[1] - 41) / speed
			if anim_menu_cmd[1] ~= 41 then
				local progress = deltaTime / anim_duration
				if progress >= 1 then
					anim_menu_cmd[1] = 41
				else
					anim_menu_cmd[1] = anim_menu_cmd[1] - (anim_menu_cmd[1] - 41) * progress
				end
			end

			local fade_duration = math.abs(anim_menu_cmd[3] - 1.0) / (speed * 0.0062)
			if anim_menu_cmd[3] < 1.0 then
				local progress = deltaTime / fade_duration
				if progress >= 1 then
					anim_menu_cmd[3] = 1.0
				else
					anim_menu_cmd[3] = anim_menu_cmd[3] + (1.0 - 0.05) * progress
				end
			end
	
			imgui.PushStyleVar(imgui.StyleVar.Alpha, anim_menu_cmd[3])
			imgui.SetCursorPos(imgui.ImVec2(163, anim_menu_cmd[1]))
			imgui.BeginChild(u8'Редактирование команды основа', imgui.ImVec2(700, 422 - pos_Y_cmd + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			
			imgui.PushFont(font[1])
			new_draw(17, 97)
			skin.InputText(114, 31, u8'Установите команду', 'cmd.nm', 15, 553, '[%a%d+-]+')
			if cmd.nm:find('%A+') then
				local characters_to_remove = {
					'Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ', 'Ф', 'Ы', 'В', 'А',
					'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э', 'Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю',
					'Ё', 'й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ', 'ф', 'ы', 'в',
					'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю'
				}
				local remove_pattern = '[' .. table.concat(characters_to_remove, '') .. ']'
				cmd.nm = string.gsub(cmd.nm, remove_pattern, '')
			end
			imgui.SetCursorPos(imgui.ImVec2(35, 34))
			imgui.Text(u8'Команда   /')
			skin.Button(u8'Назначить, изменить или очистить клавишу активации', 34, 68, 633, nil, function()
				imgui.OpenPopup(u8'Клавиша активации команды')
				lockPlayerControl(true)
				current_key = {'', {}}
				edit_key = true
			end)
			
			if imgui.BeginPopupModal(u8'Клавиша активации команды', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.SetCursorPos(imgui.ImVec2(10, 10))
				if imgui.InvisibleButton(u8'##Закрыть окошко клавиш активации', imgui.ImVec2(20, 20)) then
					lockPlayerControl(false)
					edit_key = false
					imgui.CloseCurrentPopup()
				end
				imgui.SetCursorPos(imgui.ImVec2(20, 20))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemHovered() then
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
					imgui.SetCursorPos(imgui.ImVec2(16, 13))
					imgui.PushFont(fa_font[2])
					imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
					imgui.PopFont()
				else
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
				end
				imgui.SetCursorPos(imgui.ImVec2(10, 40))
				imgui.BeginChild(u8'Назначение клавиши активации', imgui.ImVec2(383, 217), false, imgui.WindowFlags.NoScrollbar)
				
				imgui.PushFont(font[4])
				imgui.SetCursorPos(imgui.ImVec2(10, 0))
				imgui.Text(u8'Нажмите сочетание клавиш для установки')
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(10, 50))
				imgui.Text(u8'Текущее сочетание:')
				imgui.SetCursorPos(imgui.ImVec2(145, 50))
				if #cmd.key == 0 then
					imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22 ,1.00), u8'Отсутствует')
				else
					local all_keys = {}
					for i = 1, #cmd.key do
						table.insert(all_keys, vkeys.id_to_name(cmd.key[i]))
					end
					imgui.TextColored(imgui.ImVec4(0.90, 0.63, 0.22 ,1.00), table.concat(all_keys, ' + '))
				end
				imgui.SetCursorPos(imgui.ImVec2(10, 80))
				imgui.Text(u8'Использовать ПКМ в комбинации с клавишами')
				imgui.PopFont()
				imgui.PopFont()
				skin.DrawFond({0, 36}, {0, 0}, {381, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
				imgui.SetCursorPos(imgui.ImVec2(342, 79))
				if skin.Switch(u8'##ПКМ в сочетании', right_mb) then right_mb = not right_mb end
				
				if imgui.IsMouseClicked(0) then
					lua_thread.create(function()
						wait(500)
						setVirtualKeyDown(3, true)
						wait(0)
						setVirtualKeyDown(3, false)
					end)
				end
				local currently_pressed_keys = rkeys.getKeys(true)
				local pr_key_num = {}
				local pr_key_name = {}
				if #currently_pressed_keys ~= 0 then
					local stop_hot = false
					for i = 1, #currently_pressed_keys do
						local parts = {}
						for part in currently_pressed_keys[i]:gmatch('[^:]+') do
							table.insert(parts, part)
						end
						if currently_pressed_keys[i] ~= '1:Left Button' and currently_pressed_keys[i] ~= '145:Scrol Lock' 
						and currently_pressed_keys[i] ~= '2:RBut' then
							table.insert(pr_key_num, tonumber(parts[1]))
							table.insert(pr_key_name, parts[2])
						else
							stop_hot = true
						end
					end
					if not stop_key_move and not stop_hot then
						current_key[1] = table.concat(pr_key_name, ' + ')
						current_key[2] = pr_key_num
						stop_key_move = true
						lua_thread.create(function()
							wait(250)
							stop_key_move = false
						end)
					end
				end
				if current_key[1] == nil then
					current_key[1] = 'nil'
				end
				if current_key[1] ~= u8'Такая комбинация уже существует' then
					imgui.PushFont(bold_font[4])
					local calc = imgui.CalcTextSize(current_key[1])
					imgui.SetCursorPos(imgui.ImVec2(192 - calc.x / 2, 116))
					if calc.x >= 385 then
						imgui.PopFont()
						imgui.PushFont(font[4])
						calc = imgui.CalcTextSize(current_key[1])
						imgui.SetCursorPos(imgui.ImVec2(192 - calc.x / 2, 126))
					end
					imgui.TextColored(imgui.ImVec4(0.08, 0.64, 0.11, 1.00), current_key[1])
					imgui.PopFont()
				else
					imgui.PushFont(font[4])
					local calc = imgui.CalcTextSize(current_key[1])
					imgui.SetCursorPos(imgui.ImVec2(192 - calc.x / 2, 126))
					imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22, 1.00), current_key[1])
					imgui.PopFont()
				end
				
				
				skin.Button(u8'Применить', 0, 180, 185, nil, function()
					local is_hot_key_done = rkeys.isHotKeyDefined(current_key[2])
					
					if #setting.cmd[select_cmd][3] ~= 0 and #current_key[2] ~= 0 then
						local comp_key = 0
						if #setting.cmd[select_cmd][3] == #current_key[2] then
							for i = 1, #setting.cmd[select_cmd][3] do
								if setting.cmd[select_cmd][3][i] == current_key[2][i] then
									comp_key = comp_key + 1
								end
							end
						end
						if comp_key == #setting.cmd[select_cmd][3] then is_hot_key_done = false end
					end
					if is_hot_key_done then current_key = {u8'Такая комбинация уже существует', {}} end
					if not is_hot_key_done then
						if right_mb then table.insert(current_key[2], 1, 2) end
						cmd.key = current_key[2]
						lockPlayerControl(false)
						edit_key = false
						imgui.CloseCurrentPopup()
					end
				end)
				skin.Button(u8'Очистить', 195, 180, 186, nil, function()
					current_key = {'', {}}
				end)
				
				imgui.EndChild()
				imgui.EndPopup()
			end
			
			new_draw(126, 50)
			skin.InputText(114, 140, u8'Введите описание', 'cmd.desc', 120, 553)
			imgui.SetCursorPos(imgui.ImVec2(35, 143))
			imgui.Text(u8'Описание')
			
			new_draw(188, 50)
			imgui.SetCursorPos(imgui.ImVec2(35, 205))
			imgui.Text(u8'Доступ к команде')
			if skin.Slider('##Доступ к команде', 'cmd.rank', 1, 10, 205, {470, 202}, '') then
				cmd.rank = round(cmd.rank, 1)
			end
			imgui.SetCursorPos(imgui.ImVec2(396, 201))
			imgui.Text(u8'с ' ..cmd.rank.. u8' ранга')
			
			new_draw(250, 84)
			skin.Button(u8'Задать или изменить аргументы', 34, 262, 633, nil, function()
				imgui.OpenPopup(u8'Редактирование аргументов')
			end)
			local all_arguments = ''
			if #cmd.arg ~= 0 then
				for ka = 1, #cmd.arg do
					all_arguments = all_arguments..' {arg'..ka..'}'
				end
			else
				all_arguments = u8' Отсутствуют'
			end
			imgui.SetCursorPos(imgui.ImVec2(35, 309))
			imgui.Text(u8'Текущие аргументы:'..all_arguments)
			
			if imgui.BeginPopupModal(u8'Редактирование аргументов', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.BeginChild(u8'Редактор аргументов', imgui.ImVec2(400, 300), false, imgui.WindowFlags.NoScrollbar)
				imgui.SetCursorPos(imgui.ImVec2(0, 0))
				if imgui.InvisibleButton(u8'##Закрыть окошко аргументов', imgui.ImVec2(20, 20)) then
					imgui.CloseCurrentPopup()
				end
				imgui.SetCursorPos(imgui.ImVec2(10, 10))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemHovered() then
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
					imgui.SetCursorPos(imgui.ImVec2(6, 3))
					imgui.PushFont(fa_font[2])
					imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
					imgui.PopFont()
				else
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
				end
				
				if #cmd.arg == 0 then
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(134, 104))
					imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), u8'Нет аргументов')
					imgui.PopFont()
				else
					for cm = 1, #cmd.arg do
						local pos_y_c = ( (cm - 1) * 40)
						new_draw(28 + pos_y_c, 30, {5, 390})
						
						imgui.SetCursorPos(imgui.ImVec2(370, 32 + pos_y_c))
						if imgui.InvisibleButton(u8'##Удалить аргумент'..cm, imgui.ImVec2(20, 20)) then table.remove(cmd.arg, cm) break end
						imgui.PushFont(fa_font[1])
						imgui.SetCursorPos(imgui.ImVec2(373, 36 + pos_y_c))
						imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), fa.ICON_TRASH)
						imgui.PopFont()
						
						imgui.SetCursorPos(imgui.ImVec2(15, 34 + pos_y_c))
						if cmd.arg[cm][1] == 0 then
							imgui.Text(cm.. u8' числовой с тегом {arg'..cm..'}')
						else
							imgui.Text(cm.. u8' текстовый с тегом {arg'..cm..'}')
						end
						skin.InputText(190, 32 + pos_y_c, u8'Название аргумента##vgas'..cm, 'cmd.arg.'..cm..'.2', 64, 170)
					end
				end
				if #cmd.arg < 5 then
					skin.Button(u8'Добавить числовой аргумент', 0, 240, 400, 25, function() 
						table.insert(cmd.arg, {0, u8'Число'})
					end)
					skin.Button(u8'Добавить текстовый аргумент', 0, 270, 400, 25, function() 
						table.insert(cmd.arg, {1, u8'Текст'})
					end)
				else
					skin.Button(u8'Добавить числовой аргумент##false_non', 0, 240, 400, 25, function() end)
					skin.Button(u8'Добавить текстовый аргумент##false_non', 0, 270, 400, 25, function() end)
				end
				
				imgui.EndChild()
				imgui.EndPopup()
			end
			
			new_draw(346, 84)
			skin.Button(u8'Задать или изменить переменные', 34, 358, 633, nil, function()
				imgui.OpenPopup(u8'Редактирование переменных')
			end)
			imgui.SetCursorPos(imgui.ImVec2(35, 405))
			imgui.Text(u8'Текущее количество переменных: '..#cmd.var)
			
			if imgui.BeginPopupModal(u8'Редактирование переменных', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.BeginChild(u8'Редактор переменных', imgui.ImVec2(400, 300), false, imgui.WindowFlags.NoScrollbar)
				imgui.SetCursorPos(imgui.ImVec2(0, 0))
				if imgui.InvisibleButton(u8'##Закрыть окошко переменных', imgui.ImVec2(20, 20)) then
					imgui.CloseCurrentPopup()
				end
				imgui.SetCursorPos(imgui.ImVec2(10, 10))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemHovered() then
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
					imgui.SetCursorPos(imgui.ImVec2(6, 3))
					imgui.PushFont(fa_font[2])
					imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
					imgui.PopFont()
				else
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
				end
				
				if #cmd.var == 0 then
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(134, 118))
					imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), u8'Нет переменных')
					imgui.PopFont()
				else
					for cm = 1, #cmd.var do
						local pos_y_c = ( (cm - 1) * 40)
						new_draw(28 + pos_y_c, 30, {5, 390})
						
						imgui.SetCursorPos(imgui.ImVec2(370, 32 + pos_y_c))
						if imgui.InvisibleButton(u8'##Удалить переменную'..cm, imgui.ImVec2(20, 20)) then 
							table.remove(cmd.var, cm)
							if #cmd.var == 0 and #cmd.act ~= 0 then
								cmd.tr_fl[1] = 0
								for m = #cmd.act, 1, -1 do
									if cmd.act[m][1] == 5 or cmd.act[m][1] == 6 or cmd.act[m][1] == 7 then
										table.remove(cmd.act, m)
										if cmd.add_f[1] then
											if m <= cmd.add_f[2] then cmd.add_f[2] = cmd.add_f[2] - 1 end
										end
									end
								end
							elseif #cmd.var == 0 then
								cmd.tr_fl[1] = 0
							end
						end
						imgui.PushFont(fa_font[1])
						imgui.SetCursorPos(imgui.ImVec2(373, 36 + pos_y_c))
						imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), fa.ICON_TRASH)
						imgui.PopFont()
						
						imgui.SetCursorPos(imgui.ImVec2(15, 34 + pos_y_c))
						imgui.Text(cm.. u8'. Тег {var'..cm..'}')
						if cmd.var[cm] ~= nil then
							skin.InputText(110, 32 + pos_y_c, u8'Значение переменной##'..cm, 'cmd.var.'..cm..'.2', 40, 250)
						end
					end
				end
				if #cmd.var < 6 then
					skin.Button(u8'Добавить новую переменную', 0, 270, 400, 25, function() 
						table.insert(cmd.var, {1, u8''})
					end)
				else
					skin.Button(u8'Добавить новую переменную##false_non', 0, 270, 400, 25, function() end)
				end
				
				imgui.EndChild()
				imgui.EndPopup()
			end
			
			new_draw(442, 44)
			imgui.SetCursorPos(imgui.ImVec2(35, 454))
			imgui.Text(u8'Задержка проигрывания отыгровки')
			skin.Slider('##Задержка проигрывания отыгровки', 'cmd.delay', 400, 10000, 205, {470, 453}, nil)
			imgui.SetCursorPos(imgui.ImVec2(417, 452))
			imgui.Text(round(cmd.delay / 1000, 0.1)..u8' сек.')
			
			new_draw(498, 44)
			imgui.SetCursorPos(imgui.ImVec2(35, 510))
			imgui.Text(u8'Не отправлять последнее сообщение в чат')
			imgui.SetCursorPos(imgui.ImVec2(639, 509))
			if skin.Switch(u8'##Не отправлять сообщение в чат', setting.not_send_chat) then setting.not_send_chat = not setting.not_send_chat save('setting') end
			local POS_Y = 560
			
			local function ic_draw(icon_circ, imvec4_ic)
				local pos_icon = {4, 0}
				local text_add_func = ''
				if icon_circ == fa.ICON_SHARE then
					text_add_func = u8'Отправить в чат'
				elseif icon_circ == fa.ICON_HOURGLASS then
					pos_icon = {6, -1}
					text_add_func = u8'Ожидание нажатия клавиши Enter'
				elseif icon_circ == fa.ICON_LIST then
					pos_icon = {4, -1}
					text_add_func = u8'Вывести информацию в чат (для себя)'
				elseif icon_circ == fa.ICON_PENCIL then
					pos_icon = {6, -1}
					text_add_func = u8'Изменить значение переменной'
				elseif icon_circ == fa.ICON_ALIGN_LEFT then
					text_add_func = u8'Комментарий'
				elseif icon_circ == fa.ICON_LIST_OL then
					pos_icon = {4, -1}
					text_add_func = u8'Диалог выбора действия'
				elseif icon_circ == fa.ICON_SIGN_OUT then
					pos_icon = {5, -1}
					text_add_func = u8'Если в диалоге                     выбран вариант'
				elseif icon_circ == fa.ICON_STOP..'2' then
					pos_icon = {6, -1}
					text_add_func = u8'Завершить вариант диалога'
				elseif icon_circ == fa.ICON_SUPERSCRIPT then
					pos_icon = {6, -1}
					text_add_func = u8'Если переменная                               равна'
				elseif icon_circ == fa.ICON_STOP..'1' then
					pos_icon = {6, -1}
					text_add_func = u8'Завершить условие переменной'
				end
				
				imgui.SetCursorPos(imgui.ImVec2(35, POS_Y + 10))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 24, p.y + 24), imgui.GetColorU32(imvec4_ic), 5, 15)
				
				imgui.PushFont(fa_font[4])
				imgui.SetCursorPos(imgui.ImVec2(35 + pos_icon[1], POS_Y + 14 + pos_icon[2]))
				imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), icon_circ)
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(648, POS_Y + 16))
				imgui.PushFont(fa_font[1])
				imgui.Text(fa.ICON_TRASH)
				imgui.PopFont()
				
				imgui.SetCursorPos(imgui.ImVec2(70, POS_Y + 13))
				imgui.Text(text_add_func)
				if icon_circ ~= fa.ICON_HOURGLASS and icon_circ ~= fa.ICON_SIGN_OUT and icon_circ ~= fa.ICON_STOP..'2' 
				and icon_circ ~= fa.ICON_SUPERSCRIPT and icon_circ ~= fa.ICON_STOP..'1' then
					imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 44))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 1), imgui.GetColorU32(imgui.ImVec4(0.50, 0.50, 0.50 ,1.00)))
				end
			end
			local function sel_add_f(pos_y_SDF, i_sel)
				if cmd.add_f[1] and cmd.add_f[2] == i_sel then
					imgui.SetCursorPos(imgui.ImVec2(23, POS_Y + pos_y_SDF))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 656, p.y + 12), imgui.GetColorU32(imgui.ImVec4(0.11, 0.70, 0.07 ,1.00)))
				end
			end
			if #cmd.act ~= 0 then
				local remove_table = {}
				local del_d = 0
				for i, v in ipairs(cmd.act) do
					imgui.SetCursorPos(imgui.ImVec2(1, POS_Y))
					if i <= 99 then
						imgui.PushFont(font[3])
						imgui.Text(tostring(i))
						imgui.PopFont()
					else
						imgui.PushFont(font[6])
						imgui.Text(tostring(i))
						imgui.PopFont()
					end
					if v[1] == 0 then
						new_draw(POS_Y, 97)
						ic_draw(fa.ICON_SHARE, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00))
						skin.InputText(35, POS_Y + 60, u8'Текст##fj'..i, 'cmd.act.'..i..'.2', 256, 630)
						imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
						if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
						
						if cmd.add_f[1] then
							imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 97))
							if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
						end
						sel_add_f(97, i)
						POS_Y = POS_Y + 109
					elseif v[1] == 1 then
						new_draw(POS_Y, 45)
						ic_draw(fa.ICON_HOURGLASS, imgui.ImVec4(0.13, 0.83, 0.24 ,1.00))
						imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
						if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
						
						if cmd.add_f[1] then
							imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 45))
							if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
						end
						sel_add_f(45, i)
						POS_Y = POS_Y + 57
					elseif v[1] == 2 then
						new_draw(POS_Y, 97)
						ic_draw(fa.ICON_LIST, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00))
						skin.InputText(35, POS_Y + 60, u8'Текст##fe3'..i, 'cmd.act.'..i..'.2', 256, 630)
						imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
						if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
						
						if cmd.add_f[1] then
							imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 97))
							if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
						end
						sel_add_f(97, i)
						POS_Y = POS_Y + 109
					elseif v[1] == 3 then
						new_draw(POS_Y, 98 + (cmd.act[i][3] * 30))
						ic_draw(fa.ICON_LIST_OL, imgui.ImVec4(0.88, 0.18, 0.20 ,1.00))
						
						imgui.SetCursorPos(imgui.ImVec2(250, POS_Y + 22))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.7, p.y + 0.5), 10, imgui.GetColorU32(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00)), 60)
						
						if v[2] <= 9 then
							imgui.SetCursorPos(imgui.ImVec2(245, POS_Y + 14))
						else
							imgui.SetCursorPos(imgui.ImVec2(241, POS_Y + 14))
						end
						imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00), tostring(cmd.act[i][2]))
						
						for d = 1, v[3] do
							imgui.SetCursorPos(imgui.ImVec2(34, POS_Y + 32 + (d * 30)))
							imgui.Text(d..u8' Действие')
							skin.InputText(125, POS_Y + 30 + (d * 30), u8'Имя действия##'..i..d, 'cmd.act.'..i..'.4.'..d, 40, 500)
						end
						
						if v[3] >= 3 then
							for d = 3, v[3] do
								imgui.SetCursorPos(imgui.ImVec2(648, POS_Y + 34 + (d * 30)))
								imgui.PushFont(fa_font[1])
								imgui.Text(fa.ICON_TRASH)
								imgui.PopFont()
								imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 30 + (d * 30)))
								if imgui.InvisibleButton(u8'##Удалить действие диалога'..i..d, imgui.ImVec2(20, 20)) then
									table.remove(v[4], d)
									v[3] = v[3] - 1
									for h = 1, #cmd.act do
										if cmd.act[h][1] == 8 then
											if tonumber(cmd.act[h][2]) == cmd.act[i][2] then
												if tonumber(cmd.act[h][3]) >= d then
													local poike = tonumber(cmd.act[h][3])
													poike = poike - 1
													cmd.act[h][3] = tostring(poike)
												end
											end
										end
									end
								end
							end
						end
						if v[3] <= 4 then
							skin.Button(u8'Добавить##'..i, 34, POS_Y + 60 + (v[3] * 30), 100, 23, function()
								v[3] = v[3] + 1
								table.insert(v[4], u8'Действие '..v[3])
							end)
						else
							skin.Button(u8'Добавить##false_non', 34, POS_Y + 60 + (v[3] * 30), 100, 23, function() end)
						end
						
						imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
						if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then
							for k, m in ipairs(cmd.act) do
								if m[1] == 3 then
									if m[2] > v[2] then
										m[2] = m[2] - 1
									end
								elseif m[1] == 8 then
									if tonumber(m[2]) > v[2] then
										local pokat = tonumber(m[2])
										pokat = pokat - 1
										m[2] = tostring(pokat)
									elseif tonumber(m[2]) == v[2] then
										table.insert(remove_table, k)
										cmd.tr_fl[3] = cmd.tr_fl[3] - 1
									end
								end
							end
							table.insert(remove_table, i)
							cmd.tr_fl[2] = cmd.tr_fl[2] - 1
							del_d = del_d + 1
						end
						
						if cmd.add_f[1] then
							imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 98 + (cmd.act[i][3] * 30)))
							if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
						end
						sel_add_f(98 + (cmd.act[i][3] * 30), i)
						POS_Y = POS_Y + 110 + (cmd.act[i][3] * 30)
					elseif v[1] == 4 then
						new_draw(POS_Y, 97, nil, 'comm')
						ic_draw(fa.ICON_ALIGN_LEFT, imgui.ImVec4(0.88, 0.81, 0.18 ,1.00))
						skin.InputText(35, POS_Y + 60, u8'Текст комментария##'..i, 'cmd.act.'..i..'.2', 256, 630)
						imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
						if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
						
						if cmd.add_f[1] then
							imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 97))
							if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
						end
						sel_add_f(97, i)
						POS_Y = POS_Y + 109
					elseif v[1] == 5 then
						new_draw(POS_Y, 97)
						ic_draw(fa.ICON_PENCIL, imgui.ImVec4(0.83, 0.13, 0.41 ,1.00))
						local var_sum = {}
						for k = 1, #cmd.var do
							var_sum[k] = '{var'..k..'}'
						end
						skin.List({36, POS_Y + 56}, cmd.act[i][2], var_sum, 185, 'cmd.act.'..i..'.2')
						skin.InputText(235, POS_Y + 60, u8'Новое значение##'..i, 'cmd.act.'..i..'.3', 256, 430)
						imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
						if imgui.InvisibleButton(u8'##Удалить действие'..i, imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
						
						if cmd.add_f[1] then
							imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 97))
							if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
						end
						sel_add_f(97, i)
						POS_Y = POS_Y + 109
					elseif v[1] == 6 then
						new_draw(POS_Y, 43)
						ic_draw(fa.ICON_SUPERSCRIPT, imgui.ImVec4(1.00, 0.21, 0.41 ,1.00))
						local all_var = {}
						for j = 1, #cmd.var do
							all_var[j] = '{var'..j..'}'
						end
						skin.List({190, POS_Y + 6}, v[2], all_var, 100, 'cmd.act.'..i..'.2')
						skin.InputText(345, POS_Y + 10, u8'Значение переменной##'..i, 'cmd.act.'..i..'.3', 256, 260)
						imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
						if imgui.InvisibleButton(u8'##Удалить действие'..i, imgui.ImVec2(20, 20)) then 
							table.insert(remove_table, i)
							cmd.tr_fl[1] = cmd.tr_fl[1] - 1
							if cmd.tr_fl[1] == 0 then
								for j = 1, #cmd.act do
									if cmd.act[j][1] == 7 then table.insert(remove_table, i) end
								end
							end
						end
						
						if cmd.add_f[1] then
							imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 43))
							if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
						end
						sel_add_f(43, i)
						POS_Y = POS_Y + 55
					elseif v[1] == 7 then
						new_draw(POS_Y, 43)
						ic_draw(fa.ICON_STOP..'1', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00))
						imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
						if imgui.InvisibleButton(u8'##Удалить действие'..i, imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
						
						if cmd.add_f[1] then
							imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 43))
							if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
						end
						sel_add_f(43, i)
						POS_Y = POS_Y + 55
					elseif v[1] == 8 then
						new_draw(POS_Y, 43)
						ic_draw(fa.ICON_SIGN_OUT, imgui.ImVec4(0.83, 0.13, 0.41 ,1.00))
						local all_dialogs = { 0, {}, {} }
						for j = 1, #cmd.act do
							if cmd.act[j][1] == 3 then
								all_dialogs[1] = all_dialogs[1] + 1
								table.insert(all_dialogs[2], tostring(all_dialogs[1]))
							end
						end
						for j = 1, #cmd.act do
							if cmd.act[j][1] == 3 then
								if cmd.act[j][2] == tonumber(cmd.act[i][2]) then
									all_dialogs[1] = 0
									for h = 1, cmd.act[j][3] do
										all_dialogs[1] = all_dialogs[1] + 1
										table.insert(all_dialogs[3], tostring(all_dialogs[1]))
									end
								end
							end
						end
						skin.List({176, POS_Y + 6}, v[2], all_dialogs[2], 60, 'cmd.act.'..i..'.2')
						skin.List({360, POS_Y + 6}, v[3], all_dialogs[3], 60, 'cmd.act.'..i..'.3')
						imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
						if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then
							table.insert(remove_table, i)
							cmd.tr_fl[3] = cmd.tr_fl[3] - 1
							for s = 1, #cmd.act do
								if cmd.act[s][1] == 9 then
									if tonumber(cmd.act[s][2]) == tonumber(v[2]) then
										table.insert(remove_table, s)
									end
								end
							end
						end
						
						if cmd.add_f[1] then
							imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 43))
							if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
						end
						sel_add_f(43, i)
						POS_Y = POS_Y + 55
					elseif v[1] == 9 then
						new_draw(POS_Y, 43)
						ic_draw(fa.ICON_STOP..'2', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00))
						imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
						if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
						
						if cmd.add_f[1] then
							imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 43))
							if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
						end
						sel_add_f(43, i)
						POS_Y = POS_Y + 55
					end
				end
				
				if #remove_table ~= 0 then
					local function reverseCompare(a_t, b_t)
						return a_t > b_t
					end
					table.sort(remove_table, reverseCompare)
					for back = 1, #remove_table do
						table.remove(cmd.act, remove_table[back])
						if cmd.add_f[1] then
							if remove_table[back] <= cmd.add_f[2] then cmd.add_f[2] = cmd.add_f[2] - 1 end
						end
					end
					remove_table = {}
				end
				cmd.num_d = cmd.num_d - del_d
			end
			
			imgui.PushFont(font[4])
			imgui.SetCursorPos(imgui.ImVec2(197, POS_Y + 13))
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), u8'Варианты следующего действия')
			imgui.PopFont()
			imgui.PushFont(fa_font[5])
			imgui.SetCursorPos(imgui.ImVec2(487, POS_Y + 12))
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), fa.ICON_ANGLE_DOWN)
			imgui.PopFont()
			
			local function dr_circuit(y_pos_plus, icon_circ, imvec4_ic)
				local return_bool = false
				
				local pos_icon = {4, 0}
				local text_add_func = ''
				if icon_circ == fa.ICON_SHARE then
					text_add_func = u8'Отправить в чат'
				elseif icon_circ == fa.ICON_HOURGLASS then
					pos_icon = {6, -1}
					text_add_func = u8'Ожидание нажатия клавиши Enter'
				elseif icon_circ == fa.ICON_LIST then
					pos_icon = {4, -1}
					text_add_func = u8'Вывести информацию в чат (для себя)'
				elseif icon_circ == fa.ICON_PENCIL then
					pos_icon = {6, -1}
					text_add_func = u8'Изменить значение переменной'
				elseif icon_circ == fa.ICON_ALIGN_LEFT then
					text_add_func = u8'Комментарий'
				elseif icon_circ == fa.ICON_LIST_OL then
					pos_icon = {4, -1}
					text_add_func = u8'Диалог выбора дальнейшего действия'
				elseif icon_circ == fa.ICON_SIGN_OUT then
					pos_icon = {5, -1}
					text_add_func = u8'Если выбран вариант диалога...'
				elseif icon_circ == fa.ICON_STOP..'2' then
					pos_icon = {6, -1}
					text_add_func = u8'Завершить диалог'
				elseif icon_circ == fa.ICON_SUPERSCRIPT then
					pos_icon = {6, -1}
					text_add_func = u8'Если переменная равна...'
				elseif icon_circ == fa.ICON_STOP..'1' then
					pos_icon = {6, -1}
					text_add_func = u8'Завершить условие переменной'
				end
				
				imgui.SetCursorPos(imgui.ImVec2(100, POS_Y + y_pos_plus))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 500, p.y + 34), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 8, 15)
				imgui.SetCursorPos(imgui.ImVec2(100, POS_Y + y_pos_plus))
				if imgui.InvisibleButton(u8'##Добавить функцию в редакторе'..POS_Y + y_pos_plus..icon_circ, imgui.ImVec2(500, 34)) then return_bool = true end
				if imgui.IsItemActive() then
					imgui.SetCursorPos(imgui.ImVec2(101, POS_Y + y_pos_plus + 1))
					local p = imgui.GetCursorScreenPos()
					
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 498, p.y + 32), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 498, p.y + 32), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
					end
				end
				
				imgui.SetCursorPos(imgui.ImVec2(105, POS_Y + y_pos_plus + 5))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 24, p.y + 24), imgui.GetColorU32(imvec4_ic), 5, 15)
				
				imgui.PushFont(fa_font[4])
				imgui.SetCursorPos(imgui.ImVec2(580, POS_Y + y_pos_plus + 9))
				imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_PLUS)
				imgui.SetCursorPos(imgui.ImVec2(105 + pos_icon[1], POS_Y + y_pos_plus + 9 + pos_icon[2]))
				imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), icon_circ)
				imgui.PopFont()
				
				imgui.SetCursorPos(imgui.ImVec2(140, POS_Y + y_pos_plus + 8))
				imgui.Text(text_add_func)
				
				return return_bool
			end
			
			local num_a = #cmd.act + 1
			
			if cmd.add_f[1] and #cmd.act ~= 0 then
				num_a = cmd.add_f[2] + 1
			end
			
			if dr_circuit(50, fa.ICON_SHARE, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00)) then
				if not cmd.add_f[1] or #cmd.act == 0 then
					cmd.act[num_a] = {0, u8''}
				elseif cmd.add_f[1] and #cmd.act ~= 0 then
					table.insert(cmd.act, num_a, {0, u8''})
					cmd.add_f[2] = cmd.add_f[2] + 1
				end
			end
			if dr_circuit(90, fa.ICON_HOURGLASS, imgui.ImVec4(0.13, 0.83, 0.24 ,1.00)) then
				if not cmd.add_f[1] or #cmd.act == 0 then
					cmd.act[num_a] = {1, u8''}
				elseif cmd.add_f[1] and #cmd.act ~= 0 then
					table.insert(cmd.act, num_a, {1, u8''})
					cmd.add_f[2] = cmd.add_f[2] + 1
				end
			end
			if dr_circuit(130, fa.ICON_LIST, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00)) then
				if not cmd.add_f[1] or #cmd.act == 0 then
					cmd.act[num_a] = {2, u8''}
				elseif cmd.add_f[1] and #cmd.act ~= 0 then
					table.insert(cmd.act, num_a, {2, u8''})
					cmd.add_f[2] = cmd.add_f[2] + 1
				end
			end
			if dr_circuit(170, fa.ICON_LIST_OL, imgui.ImVec4(0.88, 0.18, 0.20 ,1.00)) then
				if not cmd.add_f[1] or #cmd.act == 0 then
					cmd.act[num_a] = {3, cmd.num_d, 2, {u8'Действие 1', u8'Действие 2'}}
				elseif cmd.add_f[1] and #cmd.act ~= 0 then
					table.insert(cmd.act, num_a, {3, cmd.num_d, 2, {u8'Действие 1', u8'Действие 2'}})
					cmd.add_f[2] = cmd.add_f[2] + 1
				end
				cmd.num_d = cmd.num_d + 1
				cmd.tr_fl[2] = cmd.tr_fl[2] + 1
			end
			if dr_circuit(210, fa.ICON_ALIGN_LEFT, imgui.ImVec4(0.88, 0.81, 0.18 ,1.00)) then
				if not cmd.add_f[1] or #cmd.act == 0 then
					cmd.act[num_a] = {4, u8''}
				elseif cmd.add_f[1] and #cmd.act ~= 0 then
					table.insert(cmd.act, num_a, {4, u8''})
					cmd.add_f[2] = cmd.add_f[2] + 1
				end
			end
			local res_pos = 250
			if #cmd.var ~= 0 then
				if dr_circuit(res_pos, fa.ICON_PENCIL, imgui.ImVec4(0.83, 0.13, 0.41 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {5, '{var1}', u8''}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {5, '{var1}', u8''})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
				end
				res_pos = res_pos + 40
				if dr_circuit(res_pos, fa.ICON_SUPERSCRIPT, imgui.ImVec4(1.00, 0.21, 0.41 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {6, '{var1}', ''}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {6, '{var1}', ''})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
					cmd.tr_fl[1] = cmd.tr_fl[1] + 1
				end
				res_pos = res_pos + 40
			end
			
			if cmd.tr_fl[1] ~= 0 then
				if dr_circuit(res_pos, fa.ICON_STOP..'1', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {7, '{var1}'}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {7, ''})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
				end
				res_pos = res_pos + 40
			end
			if cmd.tr_fl[2] ~= 0 then
				if dr_circuit(res_pos, fa.ICON_SIGN_OUT, imgui.ImVec4(1.00, 0.21, 0.41 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {8, '1', '1'}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {8, '1', '1'})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
					cmd.tr_fl[3] = cmd.tr_fl[3] + 1
				end
				res_pos = res_pos + 40
			end
			if cmd.tr_fl[2] ~= 0 and cmd.tr_fl[3] ~= 0 then
				if dr_circuit(res_pos, fa.ICON_STOP..'2', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {9, '1', '1'}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {9, ''})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
				end
				res_pos = res_pos + 40
			end
			
			if not cmd.add_f[1] and #cmd.act >= 2 then
				skin.Button(u8'Добавлять в конец', 100, POS_Y + res_pos + 30, 245, 25, function() cmd.add_f[1] = false end)
				skin.Button(u8'Добавлять в место##false_func', 352, POS_Y + res_pos + 30, 245, 25, function() cmd.add_f[1] = true cmd.add_f[2] = #cmd.act end)
				res_pos = res_pos + 60
			elseif cmd.add_f[1] and #cmd.act >= 2 then 
				skin.Button(u8'Добавлять в конец##false_func', 100, POS_Y + res_pos + 30, 245, 25, function() cmd.add_f[1] = false end)
				skin.Button(u8'Добавлять в место', 352, POS_Y + res_pos + 30, 245, 25, function() cmd.add_f[1] = true cmd.add_f[2] = #cmd.act end)
				res_pos = res_pos + 60
			end
			
			skin.Button(u8'Посмотреть доступные теги', 100, POS_Y + res_pos + 30, 495, 35, function()
				imgui.OpenPopup(u8'Просмотр доступных тегов')
			end)
			
			if imgui.BeginPopupModal(u8'Просмотр доступных тегов', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.SetCursorPos(imgui.ImVec2(10, 10))
				if imgui.InvisibleButton(u8'##Закрыть окошко тегов', imgui.ImVec2(20, 20)) then
					imgui.CloseCurrentPopup()
				end
				imgui.SetCursorPos(imgui.ImVec2(20, 20))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemHovered() then
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
					imgui.SetCursorPos(imgui.ImVec2(16, 13))
					imgui.PushFont(fa_font[2])
					imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
					imgui.PopFont()
				else
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
				end
				imgui.SetCursorPos(imgui.ImVec2(10, 35))
				imgui.BeginChild(u8'Просмотр тегов', imgui.ImVec2(600, 400), false, imgui.WindowFlags.NoScrollbar)
				
				local function tag_hint_text(numb_str, text_one_t, text_two_t)
					local col_text_srt_t = '{000000}'
					if setting.int.theme ~= 'White' then col_text_srt_t = '{FFFFFF}' end
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(10, 5 + ((numb_str - 1) * 30)))
					imgui.TextColoredRGB('{EBA031}'..text_one_t..' - '..col_text_srt_t..text_two_t)
					imgui.PopFont()
				end
				
				tag_hint_text(1, '{mynick}', 'Выведет Ваш никнейм на английском')
				tag_hint_text(2, '{myid}', 'Выведет Ваш id')
				tag_hint_text(3, '{mynickrus}', 'Выведет Ваш никнейм на русском')
				tag_hint_text(4, '{myrank}', 'Выведет Вашу должность')
				tag_hint_text(5, '{time}', 'Выведет текущее время')
				tag_hint_text(6, '{day}', 'Выведет текущий день')
				tag_hint_text(7, '{week}', 'Выведет текущую неделю')
				tag_hint_text(8, '{month}', 'Выведет текущий месяц')
				tag_hint_text(9, '{getplnick[ID]}', 'Выведет ник игрока по его ID')
				tag_hint_text(10, '{med7}', 'Выведет цену на новую мед. карту на 7 дней')
				tag_hint_text(11, '{med14}', 'Выведет цену на новую мед. карту на 14 дней')
				tag_hint_text(12, '{med30}', 'Выведет цену на новую мед. карту на 30 дней')
				tag_hint_text(13, '{med60}', 'Выведет цену на новую мед. карту на 60 дней')
				tag_hint_text(14, '{medup7}', 'Выведет цену на обновлённую мед. карту на 7 дней')
				tag_hint_text(15, '{medup14}', 'Выведет цену на обновлённую мед. карту на 14 дней')
				tag_hint_text(16, '{medup30}', 'Выведет цену на обновлённую мед. карту на 30 дней')
				tag_hint_text(17, '{medup60}', 'Выведет цену на обновлённую мед. карту на 60 дней')
				tag_hint_text(18, '{pricenarko}', 'Выведет цену на снятие наркозависимости')
				tag_hint_text(19, '{pricerecept}', 'Выведет цену на рецепт')
				tag_hint_text(20, '{pricetatu}', 'Выведет цену удаление татуировки с тела')
				tag_hint_text(21, '{priceant }', 'Выведет цену на антибиотик')
				tag_hint_text(22, '{pricelec }', 'Выведет цену на лечение')
				tag_hint_text(23, '{sex:муж,жен}', 'Добавит текст в соответствии с выбранным полом')
				tag_hint_text(24, '{dialoglic[id лицензии][id срока][id игрока]}', 'Автовыбор диалога с лицензией')
				tag_hint_text(25, '{target}', 'Выведет id с последнего прицела на игрока')
				tag_hint_text(26, '{prtsc}', 'Сделает скриншот игры F8')
				
				imgui.EndChild()
				
				imgui.EndPopup()
			end
			--[[
			0 - Отправить в чат
			1 - Ожидание нажатия Enter
			2 - Вывести инфо в чат
			3 - Диалог выбора действия
			4 - Комментарий
			5 - Изменить переменную
			6 - Если переменная равна
			7 - Завершить условие переменной
			8 - Если выбран вариант диалога
			9 - Завершить диалог
			]]
			
			imgui.Dummy(imgui.ImVec2(0, 90))
			
			
			
			imgui.PopFont()
			imgui.EndChild()
			imgui.PopStyleVar(1)
		end
		
	----> [3] Шпоры
	elseif select_main_menu[3] and select_shpora == 0 then
		local function new_draw(pos_draw, par_dr_y)
			imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
		end
		menu_draw_up(u8'Шпоры')
		
		imgui.PushFont(fa_font[1])
		imgui.SetCursorPos(imgui.ImVec2(826, 11))
		imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 4)
		if imgui.Button(u8'##Добавить шпаргалку', imgui.ImVec2(22, 22)) then
			local comp = 1
			local num_el = {}
			if #setting.shpora ~= 0 then
				for _, element in ipairs(setting.shpora) do
					if string.match(element[1], '^shpora%d+$') then
						table.insert(num_el, tonumber(string.match(element[1], '^shpora(%d+)$')))
					end
				end
			end
			if num_el ~= 0 then
				table.sort(num_el)
				for i = 1, #num_el do
					if num_el[i] ~= comp then
						break
					else
						comp = comp + 1
					end
				end
			end
			table.insert(setting.shpora, {'shpora'..comp, ''})
			save('setting')
			shpora = {
				nm = 'shpora'..comp,
				text = ''
			}
			local f = io.open(dirml..'/StateHelper/Шпаргалки/shpora'..comp..'.txt', 'w')
			f:write(u8:decode(shpora.text))
			f:flush()
			f:close()
			select_shpora = #setting.shpora
			anim_menu_shpora[1] = 0
			anim_menu_shpora[3] = false
			anim_menu_shpora[4] = 0
		end
		imgui.PopStyleVar(1)
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(255, 255, 255, 255):GetVec4())
		imgui.SetCursorPos(imgui.ImVec2(830, 17))
		imgui.Text(fa.ICON_PLUS)
		imgui.PopStyleColor(1)
		imgui.PopFont()
		
		local speed = 710
		local target_value = anim_menu_shpora[3] and 120 or 0
		local currentTime = os.clock()
		local deltaTime = currentTime - anim_menu_shpora[2]
		anim_menu_shpora[2] = currentTime

		local target_value = anim_menu_shpora[3] and 120 or 0

		if anim_menu_shpora[1] < target_value then
			anim_menu_shpora[1] = math.min(anim_menu_shpora[1] + speed * deltaTime, target_value)
		elseif anim_menu_shpora[1] > target_value then
			anim_menu_shpora[1] = math.max(anim_menu_shpora[1] - speed * deltaTime, target_value)
		end
		
		if not anim_menu_shpora[3] then
			if anim_menu_shpora[1] == 0 then anim_menu_shpora[4] = 0 end
		end
	
		imgui.SetCursorPos(imgui.ImVec2(180, 41))
		imgui.BeginChild(u8'Шпаргалка', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
		if #setting.shpora == 0 then
			imgui.PushFont(bold_font[4])
			imgui.SetCursorPos(imgui.ImVec2(137, 187 + ((start_pos + new_pos) / 2)))
			imgui.Text(u8'Нет ни одной шпаргалки')
			imgui.PopFont()
		else
			if anim_menu_shpora[1] == 0 then
				new_draw(17, -1 + (#setting.shpora * 68))
			else
				imgui.SetCursorPos(imgui.ImVec2(0, 17))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + -1 + (#setting.shpora * 68)), imgui.GetColorU32(imgui.ImVec4(0.70, 0.70, 0.70, 1.00)), 8, 15)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + -1 + (#setting.shpora * 68)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 8, 15)
				end
			end
			imgui.PushFont(font[1])
			local remove_shpora
			for i = 1, #setting.shpora do
				imgui.SetCursorPos(imgui.ImVec2(0 - anim_menu_shpora[1], 17 + ( (i - 1) * 68)))
				if imgui.InvisibleButton(u8'##Перейти в редактор шпаргалки'..i, imgui.ImVec2(666, 68)) then
					anim_menu_shpora[2] = os.clock()
					anim_menu_shpora[3] = not anim_menu_shpora[3]
					if anim_menu_shpora[4] == 0 then
						anim_menu_shpora[4] = i
					end
				end
				imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemActive() and anim_menu_shpora[1] == 0 then
					if i == 1 and #setting.shpora ~= 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 3)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 3)
						end
					elseif i == 1 and #setting.shpora == 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 15)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 15)
						end 
					elseif i == #setting.shpora then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 12)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 12)
						end
					else
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 0)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 0)
						end
					end
				end
				imgui.PushFont(fa_font[5])
				if anim_menu_shpora[4] ~= i and anim_menu_shpora[1] == 0 then
					imgui.SetCursorPos(imgui.ImVec2(640, 37 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
					imgui.Text(fa.ICON_ANGLE_RIGHT)
					imgui.PopStyleColor(1)
					imgui.PopFont()
					
					imgui.SetCursorPos(imgui.ImVec2(17, 31 + ( (i - 1) * 68)))
					imgui.Text(setting.shpora[i][1])
					imgui.SetCursorPos(imgui.ImVec2(17, 51 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.60))
					if setting.shpora[i][2]:gsub('%s', '') == '' then
						imgui.Text(u8'Без текста')
					else
						imgui.Text(setting.shpora[i][2])
					end
					imgui.PopStyleColor(1)
				elseif anim_menu_shpora[4] ~= i and anim_menu_shpora[1] ~= 0 then
					imgui.SetCursorPos(imgui.ImVec2(640, 37 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.20))
					imgui.Text(fa.ICON_ANGLE_RIGHT)
					imgui.PopStyleColor(1)
					imgui.PopFont()
					
					imgui.SetCursorPos(imgui.ImVec2(17, 31 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.20))
					imgui.Text(setting.shpora[i][1])
					imgui.PopStyleColor(1)
					imgui.SetCursorPos(imgui.ImVec2(17, 51 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.10))
					if setting.shpora[i][2]:gsub('%s', '') == '' then
						imgui.Text(u8'Без текста')
					else
						imgui.Text(setting.shpora[i][2])
					end
					imgui.PopStyleColor(1)
				end
				
				if anim_menu_shpora[4] == i then
					imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
					local p = imgui.GetCursorScreenPos()
					if i == 1 and #setting.shpora ~= 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 18)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 18)
						end
					elseif i == 1 and #setting.shpora == 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 22)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 22)
						end 
					elseif i == #setting.shpora then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 20)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 20)
						end
					else
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 0)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 8, 0)
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
					if imgui.InvisibleButton(u8'##Удалить команду', imgui.ImVec2(60, 68)) then
						remove_shpora = i
						anim_menu_shpora[3] = false
						anim_menu_shpora[1] = 0
						anim_menu_shpora[4] = 0
					end
					
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
						local p = imgui.GetCursorScreenPos()
						if i == 1 and #setting.shpora ~= 1 then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 18)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 18)
							end
						elseif i == 1 and #setting.shpora == 1 then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 22)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 22)
							end 
						elseif i == #setting.shpora then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 20)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 20)
							end
						else
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 0)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 8, 0)
							end
						end
					end
					
					imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
					local p = imgui.GetCursorScreenPos()
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.57, 0.04, 1.00)))
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.57, 0.04, 1.00)))
					end
					imgui.SetCursorPos(imgui.ImVec2(626, 38 + ( (i - 1) * 68)))
					imgui.PushFont(fa_font[5])
					imgui.Text(fa.ICON_TRASH)
					imgui.SetCursorPos(imgui.ImVec2(566, 38 + ( (i - 1) * 68)))
					imgui.Text(fa.ICON_PENCIL)
					imgui.PopFont()
					imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
					local p = imgui.GetCursorScreenPos()
					if i == 1 and #setting.shpora ~= 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 1)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 1)
						end
					elseif i == 1 and #setting.shpora == 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 9)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 9)
						end 
					elseif i == #setting.shpora then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 8)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 8)
						end
					else
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 0)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 0)
						end
					end
					
					imgui.SetCursorPos(imgui.ImVec2(640 - anim_menu_shpora[1], 37 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
					imgui.Text(fa.ICON_ANGLE_RIGHT)
					imgui.PopStyleColor(1)
					imgui.PopFont()
					
					imgui.SetCursorPos(imgui.ImVec2(17 - anim_menu_shpora[1], 31 + ( (i - 1) * 68)))
					imgui.Text(setting.shpora[i][1])
					imgui.SetCursorPos(imgui.ImVec2(17 - anim_menu_shpora[1], 51 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.60))
					if setting.shpora[i][2]:gsub('%s', '') == '' then
						imgui.Text(u8'Без текста')
					else
						imgui.Text(setting.shpora[i][2])
					end
					imgui.PopStyleColor(1)
					imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
					if imgui.InvisibleButton(u8'##Открыть шпору', imgui.ImVec2(60, 68)) then
						anim_menu_shpora[3] = false
						anim_menu_shpora[1] = 0
						anim_menu_shpora[4] = 0
						
						POS_Y = 380
						if doesFileExist(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[i][1]..'.txt') then
							local f = io.open(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[i][1]..'.txt')
							shpora = {
								nm = setting.shpora[i][1],
								text = u8(f:read('*a'))
							}
							f:close()
							select_shpora = i
						else
							remove_shpora = i
						end
					end
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
						local p = imgui.GetCursorScreenPos()
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.47, 0.04, 1.00)))
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.47, 0.04, 1.00)))
						end
						imgui.PushFont(fa_font[5])
						imgui.SetCursorPos(imgui.ImVec2(566, 38 + ( (i - 1) * 68)))
						imgui.Text(fa.ICON_PENCIL)
						imgui.PopFont()
					end
				end
			end
			if remove_shpora ~= nil then table.remove(setting.shpora, remove_shpora) save('setting') end
			if #setting.shpora > 1 then
				for draw = 1, #setting.shpora - 1 do
					if anim_menu_shpora[1] == 0 then
						skin.DrawFond({17, 16 + (draw * 68)}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
					else
						skin.DrawFond({17, 16 + (draw * 68)}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.20), 0, 0)
					end
				end
			end
			imgui.PopFont()
		end
		imgui.Dummy(imgui.ImVec2(0, 80))
		imgui.EndChild()
	elseif select_main_menu[3] and select_shpora ~= 0 then
		local function new_draw(pos_draw, par_dr_y, sizes_if_win, comm_tr)
			if sizes_if_win == nil then
				sizes_if_win = {17, 666}
			end
			imgui.SetCursorPos(imgui.ImVec2(sizes_if_win[1], pos_draw))
			local p = imgui.GetCursorScreenPos()
			if comm_tr == nil then
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
				end
			else
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(0.99, 1.00, 0.21, 0.50)), 8, 15)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(0.99, 1.00, 0.21, 0.30)), 8, 15)
				end
			end
		end
		
		if menu_draw_up(u8'Редактирование шпаргалки', true) then
			imgui.OpenPopup(u8'Дальнейшие действия с шпаргалкой')
			shpora_err_nm = false
		end
		imgui.PushFont(font[1])
		skin.Button(u8'Открыть для просмотра', 666, 9, 180, 26, function() 
			text_spur = shpora.text
			win.spur_big.v = true
		end)
		imgui.PopFont()
		if imgui.BeginPopupModal(u8'Дальнейшие действия с шпаргалкой', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.BeginChild(u8'Действие с шпаргалкой', imgui.ImVec2(400, 200), false, imgui.WindowFlags.NoScrollbar)
			imgui.SetCursorPos(imgui.ImVec2(0, 0))
			if imgui.InvisibleButton(u8'##Закрыть окошко шпаргалки', imgui.ImVec2(20, 20)) then
				imgui.CloseCurrentPopup()
			end
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			local p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
				imgui.SetCursorPos(imgui.ImVec2(6, 3))
				imgui.PushFont(fa_font[2])
				imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
			end
			
			imgui.PushFont(bold_font[4])
			if not shpora_err_nm then
				imgui.SetCursorPos(imgui.ImVec2(35, 55))
				imgui.Text(u8'Выберите действие')
			else
				imgui.SetCursorPos(imgui.ImVec2(127, 39))
				imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'ОШИБКА')
				
				imgui.PushFont(font[4])
				imgui.SetCursorPos(imgui.ImVec2(86, 95))
				imgui.Text(u8'Такое имя уже существует')
				imgui.PopFont()
			end
			imgui.PopFont()
			imgui.PushFont(font[1])
			skin.Button(u8'Сохранить', 10, 167, 123, 25, function()
				for i = 1, #setting.shpora do
					if setting.shpora[i][1] == shpora.nm and i ~= select_shpora then
						shpora_err_nm = true
						break
					end
				end
				if not shpora_err_nm  then
					if doesFileExist(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[select_shpora][1]..'.txt') then
						os.remove(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[select_shpora][1]..'.txt')
					end
					local f = io.open(dirml..'/StateHelper/Шпаргалки/'..shpora.nm..'.txt', 'w')
					f:write(u8:decode(shpora.text))
					f:flush()
					f:close()
					local textes = ''
					local buf_text_shpora = imgui.ImBuffer(75)
					buf_text_shpora.v = u8:decode(shpora.text)
					buf_text_shpora.v = string.gsub(buf_text_shpora.v, '\n.+', '')
					textes = u8(buf_text_shpora.v)
					if shpora.text ~= '' and buf_text_shpora.v == '' then textes = u8'Пустая строка' end
					if textes ~= shpora.text and textes ~= u8'Пустая строка' then textes = textes..' ...' end
					setting.shpora[select_shpora] = {shpora.nm, textes}
					save('setting')
					select_shpora = 0
					imgui.CloseCurrentPopup()
				end
			end)
			skin.Button(u8'Не сохранять', 138, 167, 124, 25, function()
				select_shpora = 0
				imgui.CloseCurrentPopup()
			end)
			skin.Button(u8'Удалить', 267, 167, 123, 25, function()
				if doesFileExist(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[select_shpora][1]..'.txt') then
					os.remove(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[select_shpora][1]..'.txt')
				end
				table.remove(setting.shpora, select_shpora)
				save('setting')
				select_shpora = 0
				imgui.CloseCurrentPopup()
			end)
			imgui.PopFont()
			imgui.EndChild()
			imgui.EndPopup()
		end
		
		if select_shpora ~= 0 then
			imgui.SetCursorPos(imgui.ImVec2(163, 41))
			imgui.BeginChild(u8'Редактирование шпоры', imgui.ImVec2(700, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			
			imgui.PushFont(font[1])
			new_draw(17, 48)
			imgui.SetCursorPos(imgui.ImVec2(35, 32))
			imgui.Text(u8'Имя шпоры')
			skin.InputText(125, 30, u8'Задайте имя шпаргалки', 'shpora.nm', 95, 539, nil)
			new_draw(77, 328)
			imgui.SetCursorPos(imgui.ImVec2(25, 87))
			local text_multiline = imgui.ImBuffer(512000)
			text_multiline.v = shpora.text
			imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 0.00))
			imgui.InputTextMultiline('##Окно ввода текста шпоры', text_multiline, imgui.ImVec2(649, 318))
			imgui.PopStyleColor()
			if text_multiline.v == '' and not imgui.IsItemActive() then
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.60))
				imgui.SetCursorPos(imgui.ImVec2(29, 88))
				imgui.Text(u8'Вводите текст Вашей шпаргалки')
				imgui.PopStyleColor()
			end
			shpora.text = text_multiline.v
			imgui.PopFont()
			
			imgui.EndChild()
		end
		
	----> [4] Департамент
	elseif select_main_menu[4] then
		local function new_draw(pos_draw, par_dr_y)
			imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
		end
		menu_draw_up(u8'Департамент')
		imgui.SetCursorPos(imgui.ImVec2(180, 41))
		imgui.BeginChild(u8'Департамент', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
		new_draw(17, 44)
		imgui.PushFont(font[1])
		imgui.SetCursorPos(imgui.ImVec2(15, 29))
		imgui.Text(u8'Формат обращения')
		
		new_draw(73, 44)
		
		if skin.List({350, 24}, setting.depart.format, {u8'[ЛСМЦ] - [ЛСПД]:', u8'к ЛСПД,', u8'[Больница ЛС] - [100,3] - [Полиция ЛС]:'}, 300, 'setting.depart.format') then 
			save('setting')
			if setting.depart.format == u8'[ЛСМЦ] - [ЛСПД]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '
			elseif setting.depart.format == u8'к ЛСПД,' then
				inp_text_dep = '/d '..u8'к'..' '..setting.depart.else_tag..', '
			elseif setting.depart.format == u8'[Больница ЛС] - [100,3] - [Полиция ЛС]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '
			end
		end
		
		if setting.depart.format == u8'[ЛСМЦ] - [ЛСПД]:' then
			imgui.SetCursorPos(imgui.ImVec2(15, 85))
			imgui.Text(u8'Ваш тег')
			imgui.SetCursorPos(imgui.ImVec2(310, 85))
			imgui.Text(u8'Тег к обращаемому')
			local dans = {setting.depart.my_tag, setting.depart.else_tag}
			skin.InputText(79, 84, u8'Ваш тег', 'setting.depart.my_tag', 40, 170, nil, 'setting')
			skin.InputText(450, 84, u8'Тег к обращаемому', 'setting.depart.else_tag', 40, 200, nil, 'setting')
			if dans[1] ~= setting.depart.my_tag or dans[2] ~= setting.depart.else_tag then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '
			end
		elseif setting.depart.format == u8'к ЛСПД,' then
			imgui.SetCursorPos(imgui.ImVec2(15, 85))
			imgui.Text(u8'Тег к обращаемому')
			local dans = setting.depart.else_tag
			skin.InputText(155, 84, u8'Тег к обращаемому', 'setting.depart.else_tag', 40, 200, nil, 'setting')
			if dans ~= setting.depart.else_tag then
				inp_text_dep = '/d '..u8'к'..' '..setting.depart.else_tag..', '
			end
		elseif setting.depart.format == u8'[Больница ЛС] - [100,3] - [Полиция ЛС]:' then
			imgui.SetCursorPos(imgui.ImVec2(15, 85))
			imgui.Text(u8'Ваш тег')
			imgui.SetCursorPos(imgui.ImVec2(214, 85))
			imgui.Text(u8'Волна')
			imgui.SetCursorPos(imgui.ImVec2(403, 85))
			imgui.Text(u8'Тег к обращаемому')
			local dans = {setting.depart.my_tag, setting.depart.volna, setting.depart.else_tag}
			skin.InputText(73, 84, u8'Ваш тег', 'setting.depart.my_tag', 40, 111, nil, 'setting')
			skin.InputText(261, 84, u8'Волна', 'setting.depart.volna', 40, 111, nil, 'setting')
			skin.InputText(538, 84, u8'Обращаемому', 'setting.depart.else_tag', 40, 111, nil, 'setting')
			if dans[1] ~= setting.depart.my_tag or dans[2] ~= setting.depart.volna or dans[3] ~= setting.depart.else_tag then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '
			end
		end
		imgui.PopFont()
		imgui.PushFont(bold_font[3])
		imgui.SetCursorPos(imgui.ImVec2(270, 130))
		imgui.Text(u8'Локальный чат')
		imgui.PopFont()
		new_draw(157, 248)
		
		imgui.SetCursorPos(imgui.ImVec2(0, 157))
		imgui.BeginChild(u8'Департамент', imgui.ImVec2(667, 199), false, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
		imgui.SetScrollY(imgui.GetScrollMaxY())
		
		if #dep_history > 30 then
			for i = 1, #dep_history - 20 do
				table.remove(dep_history, 1)
			end
		end
		
		if #dep_history ~= 0 then
			start_index = math.max(#dep_history - 19, 1)
			for i = start_index, #dep_history do
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(10, 10 + ((i - 1) * 20)))
				if setting.int.theme ~= 'White' then
					imgui.TextColoredRGB('{23A6FC}'..dep_history[i])
				else
					imgui.TextColoredRGB('{005994}'..dep_history[i])
				end
				imgui.PopFont()
			end
		end
		imgui.EndChild()
		skin.InputText(10, 372, u8'Текст сообщения', 'inp_text_dep', 512, 555)
		if inp_text_dep ~= '' then
			skin.Button(u8'Отправить', 575, 369, 81, 28, function()
				sampSendChat(u8:decode(inp_text_dep))
				if setting.depart.format == u8'[ЛСМЦ] - [ЛСПД]:' then
					inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '
				elseif setting.depart.format == u8'к ЛСПД,' then
					inp_text_dep = '/d '..u8'к'..' '..setting.depart.else_tag..', '
				elseif setting.depart.format == u8'[Больница ЛС] - [100,3] - [Полиция ЛС]:' then
					inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '
				end
			end)
		else
			skin.Button(u8'Отправить##false_non', 575, 369, 81, 28, function() end)
		end
		imgui.EndChild()
	
	----> [5] Собеседование
	elseif select_main_menu[5] then
		local function new_draw(pos_draw, par_dr_y)
			imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
		end
		menu_draw_up(u8'Меню собеседования')
		imgui.SetCursorPos(imgui.ImVec2(180, 41))
		imgui.BeginChild(u8'Меню собеседования', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
		if not sobes_menu then
			new_draw(17, 43)
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(15, 29))
			imgui.Text(u8'Введите id игрока')
			skin.InputText(140, 27, u8'Укажите id игрока', 'id_sobes', 4, 150, 'num')
			if setting.sob.level ~= '' and setting.sob.legal ~= '' and setting.sob.narko ~= '' and id_sobes ~= '' then
				skin.Button(u8'Начать собеседование', 310, 24, 170, 28, function()
					if sampIsPlayerConnected(id_sobes) then
						sob_history = {}
						sob_info = {
							level = -1,
							legal = -1,
							work = -1,
							narko = -1,
							hp = -1,
							bl = -1
						}
						sobes_menu = true
						pl_sob.id = tonumber(id_sobes)
						pl_sob.nm = sampGetPlayerNickname(id_sobes)
					end
				end)
			elseif id_sobes ~= '' then
				skin.Button(u8'Начать собеседование##false_non', 310, 24, 170, 28, function() end)
				imgui.SetCursorPos(imgui.ImVec2(490, 29))
				imgui.TextColoredRGB('{cf2727}Заполните все поля ниже!')
			else
				skin.Button(u8'Начать собеседование##false_non', 310, 24, 170, 28, function() end)
				imgui.SetCursorPos(imgui.ImVec2(490, 29))
				imgui.TextColoredRGB('{cf2727}Укажите id игрока!')
			end
			imgui.PopFont()
			
			imgui.PushFont(bold_font[3])
			imgui.SetCursorPos(imgui.ImVec2(198, 75))
			imgui.Text(u8'Настройки меню собеседования')
			imgui.PopFont()
			
			new_draw(103, 103)
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(15, 115))
			imgui.Text(u8'Минимальный уровень игрока для вступления')
			imgui.SetCursorPos(imgui.ImVec2(15, 145))
			imgui.Text(u8'Минимальное значение законопослушности игрока для вступления')
			imgui.SetCursorPos(imgui.ImVec2(15, 175))
			imgui.Text(u8'Допустимое количество наркозависимости игрока для вступления')
			
			skin.InputText(531, 113, u8'Значение##1', 'setting.sob.level', 3, 120, 'num', 'setting')
			skin.InputText(531, 143, u8'Значение##2', 'setting.sob.legal', 4, 120, 'num', 'setting')
			skin.InputText(531, 173, u8'Значение##3', 'setting.sob.narko', 4, 120, 'num', 'setting')
			imgui.PopFont()
			
			imgui.PushFont(bold_font[3])
			imgui.SetCursorPos(imgui.ImVec2(251, 221))
			imgui.Text(u8'Перечень вопросов')
			imgui.PopFont()
			
			local POS_QY = 252
			imgui.PushFont(font[1])
			if #setting.sob.qq ~= 0 then
				local tabl_rem = 0
				for i = 1, #setting.sob.qq do
					new_draw(POS_QY, 106 + (#setting.sob.qq[i].q * 35))
					imgui.SetCursorPos(imgui.ImVec2(15, POS_QY + 12))
					imgui.Text(u8'Имя вопроса')
					skin.InputText(110, POS_QY + 11, u8'Задайте имя вопроса##sel'..i, 'setting.sob.qq.'..i..'.nm', 50, 541, nil, 'setting')
					if #setting.sob.qq[i].q ~= 0 then
						local tabl_rem_2 = 0
						for m = 1, #setting.sob.qq[i].q do
							skin.InputText(15, POS_QY + 55 + ((m - 1) * 35), u8'Напишите Ваше сообщение, которое отправится в чат##sel'..i..m, 'setting.sob.qq.'..i..'.q.'..m, 512, 608, nil, 'setting')
							imgui.SetCursorPos(imgui.ImVec2(630, POS_QY + 57 + ((m - 1) * 35)))
							if imgui.InvisibleButton(u8'##DEL_F'..i..m, imgui.ImVec2(20, 20)) then tabl_rem_2 = m end
							imgui.PushFont(fa_font[1])
							imgui.SetCursorPos(imgui.ImVec2(633, POS_QY + 60 + ((m - 1) * 35)))
							imgui.Text(fa.ICON_TRASH)
							imgui.PopFont()
						end
						if tabl_rem_2 ~= 0 then table.remove(setting.sob.qq[i].q, tabl_rem_2) save('setting') end
					end
					if #setting.sob.qq[i].q >= 10 then
						skin.Button(u8'Добавить ответ##false_non', 15, POS_QY + 55 + (#setting.sob.qq[i].q * 35), 150, 33, function() end)
					else
						skin.Button(u8'Добавить ответ##sel'..i, 15, POS_QY + 55 + (#setting.sob.qq[i].q * 35), 150, 33, function() 
							table.insert(setting.sob.qq[i].q, '')
							save('setting')
						end)
					end
					skin.Button(u8'Удалить вопрос##fas'..i, 180, POS_QY + 55 + (#setting.sob.qq[i].q * 35), 150, 33, function() tabl_rem = i end)
					POS_QY = POS_QY + 118 + (#setting.sob.qq[i].q * 35)
				end
				if tabl_rem ~= 0 then table.remove(setting.sob.qq, tabl_rem) save('setting') end
			end
			POS_QY = POS_QY + 2
			if #setting.sob.qq >= 26 then
				skin.Button(u8'Создать новый вопрос##false_non', 208, POS_QY, 250, 33, function() end)
			else
				skin.Button(u8'Создать новый вопрос', 208, POS_QY, 250, 33, function()
					table.insert(setting.sob.qq, {
						nm = u8'Вопрос '..(#setting.sob.qq + 1),
						q = {}
					})
					save('setting')
				end)
			end
			imgui.PopFont()
			imgui.Dummy(imgui.ImVec2(0, 20))
		else
			new_draw(17, 115)
			
			imgui.PushFont(font[4])
			local cl_nm = imgui.CalcTextSize(pl_sob.nm)
			imgui.SetCursorPos(imgui.ImVec2(332 - cl_nm.x / 2, 23))
			imgui.Text(pl_sob.nm)
			imgui.PopFont()
			skin.DrawFond({17, 52}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			skin.DrawFond({333, 60}, {0, 0}, {1, 65}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(17, 62))
			imgui.Text(u8'Лет в штате:')
			imgui.SetCursorPos(imgui.ImVec2(17, 84))
			imgui.Text(u8'Законопослушность:')
			imgui.SetCursorPos(imgui.ImVec2(17, 106))
			imgui.Text(u8'Работает:')
			imgui.SetCursorPos(imgui.ImVec2(350, 62))
			imgui.Text(u8'Наркозависимость:')
			imgui.SetCursorPos(imgui.ImVec2(350, 84))
			imgui.Text(u8'Здоровье:')
			imgui.SetCursorPos(imgui.ImVec2(350, 106))
			imgui.Text(u8'Чёрный список:')
			
			imgui.SetCursorPos(imgui.ImVec2(104, 62))
			if sob_info.level == -1 then
				imgui.TextColoredRGB('{CF0000}Неизвестно')
			elseif sob_info.level >= tonumber(setting.sob.level) then
				imgui.TextColoredRGB('{00A115}'..tostring(sob_info.level)..' из '..setting.sob.level)
			elseif sob_info.level < tonumber(setting.sob.level) then
				imgui.TextColoredRGB('{CF0000}'..tostring(sob_info.level)..' из '..setting.sob.level)
			end
			imgui.SetCursorPos(imgui.ImVec2(154, 84))
			if sob_info.legal == -1 then
				imgui.TextColoredRGB('{CF0000}Неизвестно')
			elseif sob_info.legal >= tonumber(setting.sob.legal) then
				imgui.TextColoredRGB('{00A115}'..tostring(sob_info.legal)..' из '..setting.sob.legal)
			elseif sob_info.legal < tonumber(setting.sob.legal) then
				imgui.TextColoredRGB('{CF0000}'..tostring(sob_info.legal)..' из '..setting.sob.legal)
			end
			imgui.SetCursorPos(imgui.ImVec2(86, 106))
			if sob_info.work == -1 then
				imgui.TextColoredRGB('{CF0000}Неизвестно')
			elseif sob_info.work == 0 then
				imgui.TextColoredRGB('{00A115}Безработный')
			elseif sob_info.work == 1 then
				imgui.TextColoredRGB('{CF0000}Состоит во фракции')
			end
			imgui.SetCursorPos(imgui.ImVec2(479, 62))
			if sob_info.narko == -1 then
				imgui.TextColoredRGB('{CF0000}Неизвестно')
			elseif sob_info.narko <= tonumber(setting.sob.narko) then
				imgui.TextColoredRGB('{00A115}'..tostring(sob_info.narko)..' из '..setting.sob.narko)
			elseif sob_info.narko > tonumber(setting.sob.narko) then
				imgui.TextColoredRGB('{CF0000}'..tostring(sob_info.narko)..' из '..setting.sob.narko)
			end
			imgui.SetCursorPos(imgui.ImVec2(421, 84))
			if sob_info.hp == -1 then
				imgui.TextColoredRGB('{CF0000}Неизвестно')
			elseif sob_info.hp == 0 then
				imgui.TextColoredRGB('{00A115}Псих. здоров')
			elseif sob_info.hp == 1 then
				imgui.TextColoredRGB('{CF0000}Имеются отклонения')
			end
			imgui.SetCursorPos(imgui.ImVec2(458, 106))
			if sob_info.bl == -1 then
				imgui.TextColoredRGB('{CF0000}Неизвестно')
			elseif sob_info.bl == 0 then
				imgui.TextColoredRGB('{00A115}Не состоит в ЧС')
			elseif sob_info.bl == 1 then
				imgui.TextColoredRGB('{CF0000}Состоит в ЧС')
			end
			imgui.PopFont()
			
			imgui.PushFont(font[4])
			imgui.SetCursorPos(imgui.ImVec2(270, 145))
			imgui.Text(u8'Локальный чат')
			imgui.PopFont()
			new_draw(172, 190)
			
			imgui.PushFont(font[1])
			if #setting.sob.qq ~= 0 then
				skin.Button(u8'Задать вопрос', 0, 373, 219, 32, function() imgui.OpenPopup(u8'Задать вопрос') end)
			else
				skin.Button(u8'Задать вопрос##false_non', 0, 373, 219, 32, function() end)
			end
			skin.Button(u8'Определить годность', 224, 373, 218, 32, function() imgui.OpenPopup(u8'Определение годности') end)
			skin.Button(u8'Прекратить собеседование', 447, 373, 219, 32, function()
				sobes_menu = false
				sob_history = {}
				sob_info = {
					level = -1,
					legal = -1,
					work = -1,
					narko = -1,
					hp = -1,
					bl = -1
				}
			end)
			
			if imgui.BeginPopupModal(u8'Задать вопрос', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.SetCursorPos(imgui.ImVec2(10, 10))
				if imgui.InvisibleButton(u8'##Закрыть окошко определения годности', imgui.ImVec2(20, 20)) then
					lockPlayerControl(false)
					edit_key = false
					imgui.CloseCurrentPopup()
				end
				imgui.SetCursorPos(imgui.ImVec2(20, 20))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemHovered() then
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
					imgui.SetCursorPos(imgui.ImVec2(16, 13))
					imgui.PushFont(fa_font[2])
					imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
					imgui.PopFont()
				else
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
				end
				imgui.SetCursorPos(imgui.ImVec2(10, 40))
				imgui.BeginChild(u8'Задать вопрос', imgui.ImVec2(300, 15 + (#setting.sob.qq * 35)), false, imgui.WindowFlags.NoScrollbar)
				imgui.PushFont(font[1])
				for i = 1, #setting.sob.qq do
					skin.Button(setting.sob.qq[i].nm, 15, (i - 1) * 35, 270, 28, function()
						if #setting.sob.qq[i].q ~= 0 and thread:status() == 'dead' then
							thread = lua_thread.create(function()
								for k = 1, #setting.sob.qq[i].q do
									sampSendChat(u8:decode(setting.sob.qq[i].q[k]))
									if k ~= #setting.sob.qq[i].q then wait(2100) end
								end
							end)
						end
						imgui.CloseCurrentPopup()
					end)
				end
				imgui.PopFont()
				imgui.EndChild()
				imgui.EndPopup()
			end
			
			if imgui.BeginPopupModal(u8'Определение годности', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.SetCursorPos(imgui.ImVec2(10, 10))
				if imgui.InvisibleButton(u8'##Закрыть окошко определения годности', imgui.ImVec2(20, 20)) then
					lockPlayerControl(false)
					edit_key = false
					imgui.CloseCurrentPopup()
				end
				imgui.SetCursorPos(imgui.ImVec2(20, 20))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemHovered() then
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
					imgui.SetCursorPos(imgui.ImVec2(16, 13))
					imgui.PushFont(fa_font[2])
					imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
					imgui.PopFont()
				else
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
				end
				imgui.SetCursorPos(imgui.ImVec2(10, 40))
				imgui.BeginChild(u8'Определение годности', imgui.ImVec2(300, 425), false, imgui.WindowFlags.NoScrollbar)
				imgui.PushFont(font[1])
				skin.Button(u8'Принять игрока', 15, 0, 270, 28, function()
					imgui.CloseCurrentPopup()
					sobes_menu = false
					if thread:status() == 'dead' then
						thread = lua_thread.create(function()
							sampSendChat('Отлично, Вы приняты к нам на работу!')
							wait(2100)
							sampSendChat('Сейчас я выдам Вам ключи от шкафчика с формой и другими вещами.')
							wait(2100)
							sampSendChat('/do В кармане находятся ключи от шкафчиков.')
							wait(2100)
							sampSendChat('/me потянувшись во внутренний карман, достал'.. chsex('', 'а') ..' оттуда ключ')
							wait(2100)
							sampSendChat('/me передал'.. chsex('', 'а') ..' ключ от шкафчика с формой человеку напротив')
							wait(2100)
							sampSendChat('/invite '..pl_sob.id)
							wait(2100)
							sampSendChat('/r Приветствуем нового сотрудника нашей организации - '.. pl_sob.nm:gsub('_', ' ') ..'.')
						end)
					end
				end)
				skin.Button(u8'Опечатка в паспорте (нонРП ник)', 15, 60, 270, 28, function() 
					imgui.CloseCurrentPopup()
					sobes_menu = false
					if thread:status() == 'dead' then
						thread = lua_thread.create(function()
							sampSendChat('Извините, но Вы нам не подходите. У Вас опечатка в паспорте.')
							wait(2100)
							sampSendChat('/n нонРП ник. С таким ником, к сожалению, нельзя в организацию.')
						end)
					end
				end)
				skin.Button(u8'Мало лет проживания', 15, 95, 270, 28, function() 
					imgui.CloseCurrentPopup()
					sobes_menu = false
					if thread:status() == 'dead' then
						thread = lua_thread.create(function()
							sampSendChat('Извините, но Вы нам не подходите. Ваш возраст проживания в штате слишком мал.')
							wait(2100)
							sampSendChat('Минимальный возраст проживания в годах должен быть не менее, чем '..setting.sob.level)
						end)
					end
				end)
				skin.Button(u8'Проблемы с законом', 15, 130, 270, 28, function()
					imgui.CloseCurrentPopup()
					sobes_menu = false
					if thread:status() == 'dead' then
						thread = lua_thread.create(function()
							sampSendChat('Извините, но Вы нам не подходите. У Вас проблемы с законом.')
							wait(2100)
							sampSendChat('/n Требуется минимум '..setting.sob.legal..' законопослушности.')
						end)
					end
				end)
				skin.Button(u8'Уже состоит во фракции', 15, 165, 270, 28, function()
					imgui.CloseCurrentPopup()
					sobes_menu = false
					if thread:status() == 'dead' then
						thread = lua_thread.create(function()
							sampSendChat('Извините, но Вы нам не подходите.')
							wait(2100)
							sampSendChat('На данный момент Вы уже работаете в другой организации.')
							wait(2100)
							sampSendChat('Если хотите к нам, то для начала Вам необходимо уволиться оттуда.')
						end)
					end
				end)
				skin.Button(u8'Имеет наркозависимость', 15, 200, 270, 28, function() 
					imgui.CloseCurrentPopup()
					sobes_menu = false
					if thread:status() == 'dead' then
						thread = lua_thread.create(function()
							sampSendChat('Извините, но Вы нам не подходите. У Вас имеется наркозависимость.')
							wait(2100)
							sampSendChat('Вы можете вылечиться от наркозависимости, попросив об этом врача больницы.')
						end)
					end
				end)
				skin.Button(u8'Проблемы с псих. здоровьем', 15, 235, 270, 28, function()
					imgui.CloseCurrentPopup()
					sobes_menu = false
					if thread:status() == 'dead' then
						thread = lua_thread.create(function()
							sampSendChat('Извините, но Вы нам не подходите. У Вас проблемы с псих. здоровьем.')
						end)
					end
				end)
				skin.Button(u8'Состоит в чёрном списке', 15, 270, 270, 28, function() 
					imgui.CloseCurrentPopup()
					sobes_menu = false
					if thread:status() == 'dead' then
						thread = lua_thread.create(function()
							sampSendChat('Извините, но Вы нам не подходите. Вы состоите в чёрном списке организации.')
						end)
					end
				end)
				skin.Button(u8'Нет паспорта', 15, 305, 270, 28, function() 
					imgui.CloseCurrentPopup()
					sobes_menu = false
					if thread:status() == 'dead' then
						thread = lua_thread.create(function()
							sampSendChat('Для начала собеседования необходимо предоставить паспорт.')
							wait(2100)
							sampSendChat('Получить его можно в мерии г. Лос-Сантос.')
							wait(2100)
							sampSendChat('Без него, к сожалению, продолжить мы не сможем.')
						end)
					end
				end)
				skin.Button(u8'Нет мед. карты', 15, 340, 270, 28, function() 
					imgui.CloseCurrentPopup()
					sobes_menu = false
					if thread:status() == 'dead' then
						thread = lua_thread.create(function()
							sampSendChat('Для начала собеседования необходимо предоставить медицинскую карту.')
							wait(2100)
							sampSendChat('Без неё, к сожалению, продолжить мы не сможем.')
						end)
					end
				end)
				skin.Button(u8'Нет лицензий', 15, 375, 270, 28, function() 
					imgui.CloseCurrentPopup()
					sobes_menu = false
					if thread:status() == 'dead' then
						thread = lua_thread.create(function()
							sampSendChat('Для начала собеседования необходимо предоставить пакет лицензий.')
							wait(2100)
							sampSendChat('Без них, к сожалению, продолжить мы не сможем.')
						end)
					end
				end)
				
				imgui.PopFont()
				imgui.EndChild()
				imgui.EndPopup()
			end
			
			imgui.SetCursorPos(imgui.ImVec2(0, 172))
			imgui.BeginChild(u8'Локальный чат собеседования', imgui.ImVec2(667, 141), false)
			if not imgui.IsMouseDown(1) then
				imgui.SetScrollY(imgui.GetScrollMaxY())
			end
			if #sob_history ~= 0 then
				for i = 1, #sob_history do
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(10, 10 + ((i - 1) * 20)))
					if setting.int.theme ~= 'White' then
						imgui.TextColoredRGB('{b3e6f5}'..sob_history[i])
					else
						imgui.TextColoredRGB('{464d4f}'..sob_history[i])
					end
					imgui.PopFont()
				end
			end
			imgui.EndChild()
			
			skin.InputText(10, 329, u8'Текст сообщения', 'inp_text_sob', 512, 555)
			if inp_text_sob ~= '' then
				skin.Button(u8'Отправить', 575, 326, 81, 28, function()
					sampSendChat(u8:decode(inp_text_sob))
					inp_text_sob = ''
				end)
			else
				skin.Button(u8'Отправить##false_non', 575, 326, 81, 28, function() end)
			end
		
			imgui.PopFont()
		end
		imgui.EndChild()
		
	----> [6] Напоминания
	elseif select_main_menu[6] then
		local function new_draw(pos_draw, par_dr_y)
			imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
		end
		menu_draw_up(u8'Напоминания')
		
			if setting.int.theme == 'White' then
				skin.DrawFond({162, 429 + start_pos + new_pos}, {0, 0}, {702, 35}, imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00), 15, 20)
			else
				skin.DrawFond({162, 429 + start_pos + new_pos}, {0, 0}, {702, 35}, imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00), 15, 20)
			end
			skin.DrawFond({162, 428 + start_pos + new_pos}, {-0.5, 0}, {702, 0.6}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
		if not reminder_edit then
			imgui.SetCursorPos(imgui.ImVec2(190, 446 + start_pos + new_pos))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 12, imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 60)
			imgui.SetCursorPos(imgui.ImVec2(177, 433 + start_pos + new_pos))
			if imgui.InvisibleButton(u8'##Новое напоминание', imgui.ImVec2(175, 25)) then
				reminder_buf = {
					nm = u8'Напоминание '..(#setting.reminder + 1),
					year = tonumber(os.date('%Y')),
					mon = tonumber(os.date('%m')),
					day = tonumber(os.date('%d')),
					min = tonumber(os.date('%M')),
					hour = tonumber(os.date('%H')),
					repeats = {false, false, false, false, false, false, false},
					sound = false,
					execution = false
				}
				if tonumber(os.date('%M')) <= 55 then
					reminder_buf.min = tonumber(os.date('%M')) + 2
				else
					reminder_buf.min = 0
					if tonumber(os.date('%H')) ~= 23 then
						reminder_buf.hour = tonumber(os.date('%H')) + 1
					else
						reminder_buf.hour = 0
					end
				end
				reminder_edit = true
			end
			imgui.SetCursorPos(imgui.ImVec2(212, 435 + start_pos + new_pos))
			imgui.PushFont(font[4])
			imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), u8'Напоминание')
			imgui.PopFont()
			imgui.PushFont(fa_font[1])
			imgui.SetCursorPos(imgui.ImVec2(183, 441 + start_pos + new_pos))
			imgui.Text(fa.ICON_PLUS)
			imgui.PopFont()
		else
			imgui.PushFont(font[1])
			local mont = {'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня', 'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'}
			local hr = tostring(reminder_buf.hour)
			local mn = tostring(reminder_buf.min)
			if reminder_buf.hour <= 9 then
				hr = '0'..hr
			end
			if reminder_buf.min <= 9 then
				mn = '0'..mn
			end
			local calc = imgui.CalcTextSize(reminder_buf.day..' '..u8(mont[reminder_buf.mon])..' '..reminder_buf.year..u8' г. в '..hr..':'..mn)
			imgui.SetCursorPos(imgui.ImVec2(512 - calc.x / 2, 437 + start_pos + new_pos))
			imgui.Text(reminder_buf.day..' '..u8(mont[reminder_buf.mon])..' '..reminder_buf.year..u8' г. в '..hr..':'..mn)
			imgui.PopFont()
			skin.Button(u8'Сохранить', 179, 433 + start_pos + new_pos, 180, 26, function() 
				reminder_edit = false
				table.insert(setting.reminder, 1, reminder_buf)
				save('setting')
				reminder_buf = {}
			end)
			skin.Button(u8'Удалить', 666, 433 + start_pos + new_pos, 180, 26, function()
				reminder_edit = false
				reminder_buf = {}
			end)
		end
		
		imgui.SetCursorPos(imgui.ImVec2(180, 41))
		imgui.BeginChild(u8'Напоминания', imgui.ImVec2(682, 387 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
		if not reminder_edit then
			if #setting.reminder == 0 then
				imgui.PushFont(bold_font[4])
				imgui.SetCursorPos(imgui.ImVec2(185, 170 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'Нет напоминаний')
				imgui.PopFont()
			else
				for i = 1, #setting.reminder do
					local pos_y = 17 + ((i - 1) * 107)
					imgui.SetCursorPos(imgui.ImVec2(0, pos_y))
					if imgui.InvisibleButton(u8'##Удаление напоминания'..i, imgui.ImVec2(666, 95)) then imgui.OpenPopup(u8'Удаление напоминания') remove_reminder = i end
					if imgui.IsItemActive() then
						
						if setting.int.theme == 'White' then
							skin.DrawFond({0, pos_y}, {0, 0}, {666, 95}, imgui.ImVec4(col_end.fond_two[1] - 0.14, col_end.fond_two[2] - 0.14, col_end.fond_two[3] - 0.14, 1.00), 8, 15)
						else
							skin.DrawFond({0, pos_y}, {0, 0}, {666, 95}, imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00), 8, 15)
						end
					elseif imgui.IsItemHovered() then
						if setting.int.theme == 'White' then
							skin.DrawFond({0, pos_y}, {0, 0}, {666, 95}, imgui.ImVec4(col_end.fond_two[1] - 0.08, col_end.fond_two[2] - 0.08, col_end.fond_two[3] - 0.08, 1.00), 8, 15)
						else
							skin.DrawFond({0, pos_y}, {0, 0}, {666, 95}, imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00), 8, 15)
						end
					elseif not imgui.IsItemActive() and not imgui.IsItemHovered() then
						if setting.int.theme == 'White' then
							skin.DrawFond({0, pos_y}, {0, 0}, {666, 95}, imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00), 8, 15)
						else
							skin.DrawFond({0, pos_y}, {0, 0}, {666, 95}, imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00), 8, 15)
						end
					end
					
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(17, pos_y + 12))
					if not string.match(setting.reminder[i].nm, '%S') or setting.reminder[i].nm == '' then
						imgui.Text(u8'Без содержания')
					else
						imgui.Text(setting.reminder[i].nm)
					end
					skin.DrawFond({17, pos_y + 43}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40))
					local week_dot = {u8'ПН, ', u8'ВТ, ', u8'СР, ', u8'ЧТ, ', u8'ПТ, ', u8'СБ, ', u8'ВС, '}
					local repeat_true = false
					local repeat_text = u8''
					for m = 1, #setting.reminder[i].repeats do
						if setting.reminder[i].repeats[m] then
							repeat_true = true
							repeat_text = repeat_text..week_dot[m]
						end
					end
					if repeat_true then
						repeat_text = string.gsub(repeat_text, ', $', '')
					else
						repeat_text = u8'Без повторений'
					end
					local calc = imgui.CalcTextSize(repeat_text)
					imgui.SetCursorPos(imgui.ImVec2(649 - calc.x, pos_y + 12))
					imgui.Text(repeat_text)
					skin.DrawFond({17, pos_y + 57}, {0, 0}, {4, 25}, imgui.ImVec4(1.00, 0.58, 0.02 ,1.00))
					local mont = {'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня', 'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'}
					local hr = tostring(setting.reminder[i].hour)
					local mn = tostring(setting.reminder[i].min)
					if setting.reminder[i].hour <= 9 then
						hr = '0'..hr
					end
					if setting.reminder[i].min <= 9 then
						mn = '0'..mn
					end
					imgui.SetCursorPos(imgui.ImVec2(31, pos_y + 62))
					imgui.Text(setting.reminder[i].day..' '..u8(mont[setting.reminder[i].mon])..' '..setting.reminder[i].year..u8' г. в '..hr..':'..mn)
					imgui.PopFont()
				end
				imgui.Dummy(imgui.ImVec2(0, 28))
				if imgui.BeginPopupModal(u8'Удаление напоминания', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(15, 12))
					imgui.Text(u8'Вы уверены, что хотите удалить напоминание?  ')
					skin.Button(u8'Удалить##напоминание', 15, 40, 145, 30, function() table.remove(setting.reminder, remove_reminder) save('setting') imgui.CloseCurrentPopup() end)
					skin.Button(u8'Оставить##напоминание', 170, 40, 145, 30, function() imgui.CloseCurrentPopup() end)
					imgui.PopFont()
					imgui.Dummy(imgui.ImVec2(0, 7))
					imgui.EndPopup()
				end
			end
		else
			new_draw(17, 44)
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(15, 29))
			imgui.Text(u8'Текст напоминания')
			skin.InputText(150, 28, u8'Введите текст##df', 'reminder_buf.nm', 100, 500)
			
			imgui.SetCursorPos(imgui.ImVec2(0, 73))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 450, p.y + 296), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 450, p.y + 296), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
			imgui.SetCursorPos(imgui.ImVec2(462, 73))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 81, p.y + 217), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 81, p.y + 217), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
			imgui.SetCursorPos(imgui.ImVec2(555, 73))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 111, p.y + 296), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 111, p.y + 296), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
			imgui.SetCursorPos(imgui.ImVec2(462, 302))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 81, p.y + 67), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 81, p.y + 67), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
			
			imgui.SetCursorPos(imgui.ImVec2(475, 84))
			imgui.Text(u8'ПН\n\nВТ\n\nСР\n\nЧТ\n\nПТ\n\nСБ\n\nВС')
			for i = 1, 7 do
				imgui.SetCursorPos(imgui.ImVec2(500, 82 + ((i - 1) * 30)))
				if skin.Switch(u8'##Повторение неделями'..i, reminder_buf.repeats[i]) then reminder_buf.repeats[i] = not reminder_buf.repeats[i] end
			end
			imgui.SetCursorPos(imgui.ImVec2(488, 314))
			imgui.Text(u8'Звук')
			imgui.SetCursorPos(imgui.ImVec2(488.5, 335))
			if skin.Switch(u8'##Звуковой сигнал', reminder_buf.sound) then reminder_buf.sound = not reminder_buf.sound end
			imgui.SetCursorPos(imgui.ImVec2(583, 84))
			imgui.PushFont(font[4])
			local hr = tostring(reminder_buf.hour)
			local mn = tostring(reminder_buf.min)
			if reminder_buf.hour <= 9 then
				hr = '0'..hr
			end
			if reminder_buf.min <= 9 then
				mn = '0'..mn
			end
			imgui.Text(hr..':'..mn)
			imgui.PopFont()
			skin.DrawFond({568, 116}, {0, 0}, {83, 1.0}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
			
			imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(0, 0, 0, 0):GetVec4())
			imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(0, 0, 0, 0):GetVec4())
			imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(0, 0, 0, 0):GetVec4())
			imgui.SetCursorPos(imgui.ImVec2(571, 133))
			if imgui.VSliderFloat(u8'##Часы слайдера', imgui.ImVec2(18, 220), rem_fl_h, 0, 22, '') then reminder_buf.hour = round(rem_fl_h.v, 1) end
			imgui.SetCursorPos(imgui.ImVec2(630, 133))
			if imgui.VSliderFloat(u8'##Минуты слайдера', imgui.ImVec2(18, 220), rem_fl_m, 0, 58, '') then reminder_buf.min = round(rem_fl_m.v, 1) end
			
			local col_neitral = imgui.GetColorU32(imgui.ImVec4(0.60, 0.60, 0.60, 1.00))
			if setting.int.theme == 'White' then
				col_neitral =  imgui.GetColorU32(imgui.ImVec4(0.84, 0.82, 0.82, 1.00))
			end
			imgui.SetCursorPos(imgui.ImVec2(571, 133))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 18, p.y + 219), col_neitral, 8, 15)
			imgui.SetCursorPos(imgui.ImVec2(571, 128 + (225 - (reminder_buf.hour * 9))))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 18, p.y + (reminder_buf.hour * 9)), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 8, 12)
			imgui.SetCursorPos(imgui.ImVec2(566, 113 + (225 - (reminder_buf.hour * 9))))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 28, p.y + 15), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00, 1.00)), 8, 15)
			
			imgui.SetCursorPos(imgui.ImVec2(630, 133))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 18, p.y + 219), col_neitral, 8, 15)
			imgui.SetCursorPos(imgui.ImVec2(630, 128 + (225 - (reminder_buf.min * 3.6))))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 18, p.y + (reminder_buf.min * 3.6)), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 8, 12)
			imgui.SetCursorPos(imgui.ImVec2(625, 113 + (225 - (reminder_buf.min * 3.6))))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 28, p.y + 15), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00, 1.00)), 8, 15)
			imgui.PopStyleColor(3)
			
			local month = {u8'Январь', u8'Февраль', u8'Март', u8'Апрель', u8'Май', u8'Июнь', u8'Июль', u8'Август', u8'Сентябрь', u8'Октябрь', u8'Ноябрь', u8'Декабрь'}
			imgui.SetCursorPos(imgui.ImVec2(15, 83))
			imgui.PushFont(font[4])
			imgui.Text(month[tonumber(reminder_buf.mon)]..' '..reminder_buf.year..u8' г.')
			imgui.PopFont()
			skin.DrawFond({15, 118}, {0, 0}, {420, 1.0}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
			imgui.SetCursorPos(imgui.ImVec2(373, 82))
			if imgui.InvisibleButton('##Смах влево', imgui.ImVec2(25, 25)) then
				if reminder_buf.mon == 1 then
					reminder_buf.mon = 12
					reminder_buf.year = reminder_buf.year - 1
				else
					reminder_buf.mon = reminder_buf.mon - 1
				end
				reminder_buf.day = 1
			end
			imgui.SetCursorPos(imgui.ImVec2(375, 83))
			imgui.PushFont(fa_font[5])
			if imgui.IsItemHovered() then
				imgui.TextColored(imgui.ImVec4(0.95, 0.34, 0.34 ,1.00), fa.ICON_CHEVRON_LEFT)
			else
				imgui.TextColored(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00), fa.ICON_CHEVRON_LEFT)
			end
			
			imgui.SetCursorPos(imgui.ImVec2(417, 82))
			if imgui.InvisibleButton('##Смах вправо', imgui.ImVec2(25, 25)) then
				if reminder_buf.mon == 12 then
					reminder_buf.mon = 1
					reminder_buf.year = reminder_buf.year + 1
				else
					reminder_buf.mon = reminder_buf.mon + 1
				end
				reminder_buf.day = 1
			end
			imgui.SetCursorPos(imgui.ImVec2(419, 83))
			if imgui.IsItemHovered() then
				imgui.TextColored(imgui.ImVec4(0.95, 0.34, 0.34 ,1.00), fa.ICON_CHEVRON_RIGHT)
			else
				imgui.TextColored(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00), fa.ICON_CHEVRON_RIGHT)
			end
			imgui.PopFont()
			
			local week_name = {u8'ПН', u8'ВТ', u8'СР', u8'ЧТ', u8'ПТ', u8'СБ', u8'ВС'}
			for i = 1, 7 do
				imgui.SetCursorPos(imgui.ImVec2(42 + ((i - 1) * 58), 133))
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,1.00), week_name[i])
			end
			
			local function get_first_day_of_week(month, year)
				local first_day_of_month = os.date('%w', os.time({year = year, month = month, day = 1}))
				if first_day_of_month == '0' then
					first_day_of_month = '7'
				end

				return tonumber(first_day_of_month)
			end
			local function get_days_in_month(month, year)
				local days_in_month = 31
				if month == 4 or month == 6 or month == 9 or month == 11 then
					days_in_month = 30
				elseif month == 2 then
					if year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) then
						days_in_month = 29
					else
						days_in_month = 28
					end
				end

				return days_in_month
			end
			
			local week_buf = get_first_day_of_week(reminder_buf.mon, reminder_buf.year)
			local pos_y_week = 0
			for i = 1, get_days_in_month(reminder_buf.mon, reminder_buf.year) do
				imgui.SetCursorPos(imgui.ImVec2(38 + ((week_buf - 1) * 58), 169 + (pos_y_week * 32)))
				if imgui.InvisibleButton(u8'##Номер дня'..i, imgui.ImVec2(24, 24)) then reminder_buf.day = i end
				if imgui.IsItemHovered() then
					imgui.SetCursorPos(imgui.ImVec2(51 + ((week_buf - 1) * 58), 177 + (pos_y_week * 32)))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y+0.4), 14, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.25)), 60)
				end
				if i == reminder_buf.day then
					imgui.SetCursorPos(imgui.ImVec2(51 + ((week_buf - 1) * 58), 177 + (pos_y_week * 32)))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y+0.4), 14, imgui.GetColorU32(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00)), 60)
				end
				if i >= 10 then
					imgui.SetCursorPos(imgui.ImVec2(43 + ((week_buf - 1) * 58), 169 + (pos_y_week * 32)))
				else
					imgui.SetCursorPos(imgui.ImVec2(47 + ((week_buf - 1) * 58), 169 + (pos_y_week * 32)))
				end
				imgui.Text(tostring(i))
				week_buf = week_buf + 1
				if week_buf == 8 then
					week_buf = 1
					pos_y_week = pos_y_week + 1
				end
			end
			
			imgui.PopFont()
		end
		
		imgui.EndChild()
		
	----> [7] Статистика
	elseif select_main_menu[7] then
		local function new_draw(pos_draw, par_dr_y)
			imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
		end
		local function point_sum(n)
			local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
			return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
		end
		local function earnings_text(e_text_st, e_text_sum, e_p_x, e_p_y)
			local tr_ff = false
			imgui.PushFont(font[1])
			if e_text_sum ~= 0 then
				imgui.SetCursorPos(imgui.ImVec2(e_p_x,e_p_y))
				if setting.int.theme == 'White' then
					imgui.TextColoredRGB('{000000}'.. e_text_st ..' {279643}'.. point_sum(e_text_sum) ..'$')
				else
					imgui.TextColoredRGB('{FFFFFF}'.. e_text_st ..' {36CF5C}'.. point_sum(e_text_sum) ..'$')
				end
				tr_ff = true
			end
			imgui.PopFont()
			
			return tr_ff
		end
		local function draw_button(pos_draw, text_for_draw, num_select)
			imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 351, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00)))
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 351, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00)))
			end
			imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
			if select_stat ~= num_select then
				if imgui.InvisibleButton(u8'##Сменить вкладку статистики'..pos_draw[1], imgui.ImVec2(351, 25)) then select_stat = num_select end
				if imgui.IsItemActive() then
					imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 351, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.01, col_end.fond_two[2] + 0.01, col_end.fond_two[3] + 0.01, 1.00)))
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 351, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00)))
					end
				elseif imgui.IsItemHovered() then
					imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 351, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)))
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 351, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.08, col_end.fond_two[2] + 0.08, col_end.fond_two[3] + 0.08, 1.00)))
					end
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 351, p.y + 25), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
			end
			imgui.PushFont(font[1])
			local calc = imgui.CalcTextSize(text_for_draw)
			calc = 176 - (calc.x / 2)
			imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + calc, 43))
			if setting.int.theme == 'White' and num_select == select_stat then
				imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), text_for_draw)
			else
				imgui.Text(text_for_draw)
			end
			imgui.PopFont()
		end
		menu_draw_up(u8'Статистика')
		
		draw_button({162, 40}, u8'Статистика прибыли', 0)
		draw_button({513, 40}, u8'Статистика онлайна', 1)
		
		imgui.SetCursorPos(imgui.ImVec2(180, 65))
		if select_stat == 0 then
			imgui.BeginChild(u8'Статистика прибыли', imgui.ImVec2(682, 398 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			if setting.frac.org:find(u8'Больница') then
				local non_stat = false
				local pos_y = 0
				local psl_y = 0
				
				for i = 1, 7 do
					if setting.stat.hosp.date_week[i] ~= '' then
						local money_true = 0
						non_stat = true
						if setting.stat.hosp.payday[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.hosp.lec[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.hosp.medcard[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.hosp.apt[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.hosp.ant[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.hosp.rec[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.hosp.medcam[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.hosp.tatu[i] ~= 0 then money_true = money_true + 1 end
						
						local pp_y = 0
						if money_true ~= 0 then
							local total_day = 0
							new_draw(17 + pos_y, (91 + (money_true * 23)))
							imgui.PushFont(bold_font[3])
							imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
							imgui.Text(setting.stat.hosp.date_week[i])
							local calc = imgui.CalcTextSize(setting.stat.hosp.date_week[i])
							imgui.PopFont()
							skin.DrawFond({17, 55 + pos_y}, {0, 0}, {calc.x, 4}, imgui.ImVec4(1.00, 0.58, 0.02 ,1.00))
							if earnings_text('Зарплата:', setting.stat.hosp.payday[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.payday[i] end
							if earnings_text('Лечение:', setting.stat.hosp.lec[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.lec[i] end
							if earnings_text('Оформление мед.карт:', setting.stat.hosp.medcard[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.medcard[i] end
							if earnings_text('Снятие наркозависимости:', setting.stat.hosp.apt[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.apt[i] end
							if earnings_text('Продажа антибиотиков:', setting.stat.hosp.ant[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.ant[i] end
							if earnings_text('Продажа рецептов:', setting.stat.hosp.rec[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.rec[i] end
							if earnings_text('Перевозка медикаментов:', setting.stat.hosp.medcam[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.medcam[i] end
							if earnings_text('За вызовы:', setting.stat.hosp.cure[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.cure[i] end
							if earnings_text('Сведение татуировок:', setting.stat.hosp.tatu[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.tatu[i] end
							
							imgui.PushFont(font[1])
							imgui.SetCursorPos(imgui.ImVec2(17, 79 + pos_y + pp_y))
							if setting.int.theme == 'White' then
								imgui.TextColoredRGB('{000000}Итого за день: {279643}'..point_sum(total_day)..'$')
							else
								imgui.TextColoredRGB('{FFFFFF}Итого за день: {36CF5C}'..point_sum(total_day)..'$')
							end
							imgui.PopFont()
							pos_y = pos_y + 91 + (money_true * 23) + 12
						else
							new_draw(17 + pos_y, 84)
							imgui.PushFont(font[4])
							imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
							imgui.Text(setting.stat.hosp.date_week[i])
							local calc = imgui.CalcTextSize(setting.stat.hosp.date_week[i])
							imgui.PopFont()
							skin.DrawFond({17, 55 + pos_y}, {0, 0}, {calc.x, 4}, imgui.ImVec4(1.00, 0.58, 0.02 ,1.00))
							imgui.PushFont(font[1])
							imgui.SetCursorPos(imgui.ImVec2(17, 69 + pos_y))
							imgui.Text(u8'В этот день Вы ничего не заработали')
							imgui.PopFont()
							pos_y = pos_y + 96
						end
					end
				end
				new_draw(17 + pos_y, 63)
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
				setting.stat.hosp.total_week = 0
				for i = 1, 7 do
					setting.stat.hosp.total_week = setting.stat.hosp.total_week + setting.stat.hosp.payday[i] + setting.stat.hosp.lec[i] + setting.stat.hosp.medcard[i] + setting.stat.hosp.apt[i] + setting.stat.hosp.ant[i] + setting.stat.hosp.rec[i] + setting.stat.hosp.medcam[i] + setting.stat.hosp.tatu[i]
				end
				if setting.int.theme == 'White' then
					imgui.TextColoredRGB('{000000}Итого за неделю: {279643}'..point_sum(setting.stat.hosp.total_week)..'$')
				else
					imgui.TextColoredRGB('{FFFFFF}Итого за неделю: {36CF5C}'..point_sum(setting.stat.hosp.total_week)..'$')
				end
				imgui.SetCursorPos(imgui.ImVec2(17, 49 + pos_y))
				if setting.int.theme == 'White' then
					imgui.TextColoredRGB('{000000}Итого за всё время: {279643}'..point_sum(setting.stat.hosp.total_all)..'$')
				else
					imgui.TextColoredRGB('{FFFFFF}Итого за всё время: {36CF5C}'..point_sum(setting.stat.hosp.total_all)..'$')
				end
				imgui.PopFont()
				skin.Button(u8'Сбросить статистику', 270, 98 + pos_y, 145, 30, function()
					if setting.frac.org:find(u8'Больница') then
						setting.stat.hosp = {
							payday = {0, 0, 0, 0, 0, 0, 0},
							lec = {0, 0, 0, 0, 0, 0, 0},
							medcard = {0, 0, 0, 0, 0, 0, 0},
							apt = {0, 0, 0, 0, 0, 0, 0},
							vac = {0, 0, 0, 0, 0, 0, 0},
							ant = {0, 0, 0, 0, 0, 0, 0},
							rec = {0, 0, 0, 0, 0, 0, 0},
							medcam = {0, 0, 0, 0, 0, 0, 0},
							cure = {0, 0, 0, 0, 0, 0, 0},
							tatu = {0, 0, 0, 0, 0, 0, 0},
							total_week = 0,
							total_all = 0,
							date_num = {0, 0},
							date_today = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
							date_last = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
							date_week = {os.date('%d.%m.%Y'), '', '', '', '', '', ''}
						}
					end
					save('setting')
				end)
				imgui.Dummy(imgui.ImVec2(0, 18))
				
			--[[elseif setting.frac.org:find(u8'Центр Лицензирования') then
				local non_stat = false
				local pos_y = 0
				local psl_y = 0
				
				for i = 1, 7 do
					if setting.stat.school.date_week[i] ~= '' then
						local money_true = 0
						non_stat = true
						if setting.stat.school.payday[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.school.auto[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.school.moto[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.school.fish[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.school.swim[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.school.gun[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.school.hun[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.school.exc[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.school.taxi[i] ~= 0 then money_true = money_true + 1 end
						if setting.stat.school.meh[i] ~= 0 then money_true = money_true + 1 end
						
						local pp_y = 0
						if money_true ~= 0 then
							local total_day = 0
							new_draw(17 + pos_y, (91 + (money_true * 23)))
							imgui.PushFont(font[4])
							imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
							imgui.Text(setting.stat.school.date_week[i])
							local calc = imgui.CalcTextSize(setting.stat.school.date_week[i])
							imgui.PopFont()
							skin.DrawFond({17, 55 + pos_y}, {0, 0}, {calc.x, 4}, imgui.ImVec4(1.00, 0.58, 0.02 ,1.00))
							if earnings_text('Зарплата:', setting.stat.school.payday[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.payday[i] end
							if earnings_text('Авто:', setting.stat.school.auto[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.auto[i] end
							if earnings_text('Мото:', setting.stat.school.moto[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.moto[i] end
							if earnings_text('Рыбалка:', setting.stat.school.fish[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.fish[i] end
							if earnings_text('Плавание:', setting.stat.school.swim[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.swim[i] end
							if earnings_text('Оружие:', setting.stat.school.gun[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.gun[i] end
							if earnings_text('Охота:', setting.stat.school.hun[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.hun[i] end
							if earnings_text('Раскопки:', setting.stat.school.exc[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.exc[i] end
							if earnings_text('Такси:', setting.stat.school.taxi[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.taxi[i] end
							if earnings_text('Механика:', setting.stat.school.meh[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.meh[i] end
							
							imgui.PushFont(font[1])
							imgui.SetCursorPos(imgui.ImVec2(17, 79 + pos_y + pp_y))
							if setting.int.theme == 'White' then
								imgui.TextColoredRGB('{000000}Итого за день: {279643}'..point_sum(total_day)..'$')
							else
								imgui.TextColoredRGB('{FFFFFF}Итого за день: {36CF5C}'..point_sum(total_day)..'$')
							end
							imgui.PopFont()
							pos_y = pos_y + 91 + (money_true * 23) + 12
						else
							new_draw(17 + pos_y, 84)
							imgui.PushFont(font[4])
							imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
							imgui.Text(setting.stat.school.date_week[i])
							local calc = imgui.CalcTextSize(setting.stat.school.date_week[i])
							imgui.PopFont()
							skin.DrawFond({17, 55 + pos_y}, {0, 0}, {calc.x, 4}, imgui.ImVec4(1.00, 0.58, 0.02 ,1.00))
							imgui.PushFont(font[1])
							imgui.SetCursorPos(imgui.ImVec2(17, 69 + pos_y))
							imgui.Text(u8'В этот день Вы ничего не заработали')
							imgui.PopFont()
							pos_y = pos_y + 96
						end
					end
				end
				new_draw(17 + pos_y, 63)
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
				setting.stat.school.total_week = 0
				for i = 1, 7 do
					setting.stat.school.total_week = setting.stat.school.payday[i] + setting.stat.school.auto[i] + setting.stat.school.moto[i] + 
					setting.stat.school.fish[i] + setting.stat.school.swim[i] + setting.stat.school.gun[i] + setting.stat.school.exc[i] + 
					setting.stat.school.taxi[i] + setting.stat.school.meh[i] + setting.stat.school.hun[i] + setting.stat.school.total_week
				end
				if setting.int.theme == 'White' then
					imgui.TextColoredRGB('{000000}Итого за неделю: {279643}'..point_sum(setting.stat.school.total_week)..'$')
				else
					imgui.TextColoredRGB('{FFFFFF}Итого за неделю: {36CF5C}'..point_sum(setting.stat.school.total_week)..'$')
				end
				imgui.SetCursorPos(imgui.ImVec2(17, 49 + pos_y))
				if setting.int.theme == 'White' then
					imgui.TextColoredRGB('{000000}Итого за всё время: {279643}'..point_sum(setting.stat.school.total_all)..'$')
				else
					imgui.TextColoredRGB('{FFFFFF}Итого за всё время: {36CF5C}'..point_sum(setting.stat.school.total_all)..'$')
				end
				imgui.PopFont()
				skin.Button(u8'Сбросить статистику', 270, 98 + pos_y, 145, 30, function()
					if setting.frac.org:find(u8'Центр Лицензирования') then
						setting.stat.school = {
							payday = {0, 0, 0, 0, 0, 0, 0},
							auto = {0, 0, 0, 0, 0, 0, 0},
							moto = {0, 0, 0, 0, 0, 0, 0},
							fish = {0, 0, 0, 0, 0, 0, 0},
							swim = {0, 0, 0, 0, 0, 0, 0},
							gun = {0, 0, 0, 0, 0, 0, 0},
							hun = {0, 0, 0, 0, 0, 0, 0},
							exc = {0, 0, 0, 0, 0, 0, 0},
							taxi = {0, 0, 0, 0, 0, 0, 0},
							meh = {0, 0, 0, 0, 0, 0, 0},
							total_week = 0,
							total_all = 0,
							date_num = {0, 0},
							date_today = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
							date_last = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
							date_week = {os.date('%d.%m.%Y'), '', '', '', '', '', ''}
						}
					end
					save('setting')
				end)
				imgui.Dummy(imgui.ImVec2(0, 18))]]
			else
				imgui.PushFont(bold_font[4])
				imgui.SetCursorPos(imgui.ImVec2(121, 176 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'Для Вас пока недоступно')
				imgui.PopFont()
			end
			
			imgui.EndChild()
		else
			imgui.BeginChild(u8'Статистика онлайна', imgui.ImVec2(682, 398 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			local pos_y = 17
			
			for i = 1, 7 do
				imgui.PushFont(font[1])
				if setting.online_stat.date_week[i] ~= '' then
					if i == 1 then
						new_draw(pos_y, 202)
					else
						new_draw(pos_y, 127)
					end
					imgui.PushFont(bold_font[3])
					imgui.SetCursorPos(imgui.ImVec2(17, 12 + pos_y))
					imgui.Text(setting.online_stat.date_week[i])
					local calc = imgui.CalcTextSize(setting.online_stat.date_week[i])
					imgui.PopFont()
					skin.DrawFond({17, 38 + pos_y}, {0, 0}, {calc.x, 4}, imgui.ImVec4(1.00, 0.58, 0.02 ,1.00))
					
					imgui.SetCursorPos(imgui.ImVec2(17, 52 + pos_y))
					if setting.int.theme == 'White' then
						imgui.TextColoredRGB('{000000}Чистый онлайн за день: {279643}'.. print_time(setting.online_stat.clean[i]))
					else
						imgui.TextColoredRGB('{FFFFFF}Чистый онлайн за день: {36CF5C}'.. print_time(setting.online_stat.clean[i]))
					end
					imgui.SetCursorPos(imgui.ImVec2(17, 75 + pos_y))
					if setting.int.theme == 'White' then
						imgui.TextColoredRGB('{000000}АФК за день: {279643}'.. print_time(setting.online_stat.afk[i]))
					else
						imgui.TextColoredRGB('{FFFFFF}АФК за день: {36CF5C}'.. print_time(setting.online_stat.afk[i]))
					end
					imgui.SetCursorPos(imgui.ImVec2(17, 98 + pos_y))
					if setting.int.theme == 'White' then
						imgui.TextColoredRGB('{000000}Всего за день: {279643}'.. print_time(setting.online_stat.all[i]))
					else
						imgui.TextColoredRGB('{FFFFFF}Всего за день: {36CF5C}'.. print_time(setting.online_stat.all[i]))
					end
					
					pos_y = pos_y + 144
					
					if i == 1 then
						imgui.SetCursorPos(imgui.ImVec2(17, -17 + pos_y))
						if setting.int.theme == 'White' then
							imgui.TextColoredRGB('{000000}Чистый за сессию: {279643}'.. print_time(session_clean.v))
						else
							imgui.TextColoredRGB('{FFFFFF}Чистый за сессию: {36CF5C}'.. print_time(session_clean.v))
						end
						imgui.SetCursorPos(imgui.ImVec2(17, 6 + pos_y))
						if setting.int.theme == 'White' then
							imgui.TextColoredRGB('{000000}АФК за сессию: {279643}'.. print_time(session_afk.v))
						else
							imgui.TextColoredRGB('{FFFFFF}АФК за сессию: {36CF5C}'.. print_time(session_afk.v))
						end
						imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
						if setting.int.theme == 'White' then
							imgui.TextColoredRGB('{000000}Всего за сессию: {279643}'.. print_time(session_all.v))
						else
							imgui.TextColoredRGB('{FFFFFF}Всего за сессию: {36CF5C}'.. print_time(session_all.v))
						end
						pos_y = pos_y + 75
					end
				end
				
				imgui.PopFont()
			end
				
			imgui.PushFont(font[1])
			new_draw(pos_y, 64)
			setting.online_stat.total_week = setting.online_stat.clean[1] + setting.online_stat.clean[2] + setting.online_stat.clean[3] + 
			setting.online_stat.clean[4] + setting.online_stat.clean[5] + setting.online_stat.clean[6] + setting.online_stat.clean[7]
			imgui.SetCursorPos(imgui.ImVec2(17, 11 + pos_y))
			if setting.int.theme == 'White' then
				imgui.TextColoredRGB('{000000}Чистый онлайн за неделю: {279643}'.. print_time(setting.online_stat.total_week))
			else
				imgui.TextColoredRGB('{FFFFFF}Чистый онлайн за неделю: {36CF5C}'.. print_time(setting.online_stat.total_week))
			end
			imgui.SetCursorPos(imgui.ImVec2(17, 34 + pos_y))
			if setting.int.theme == 'White' then
				imgui.TextColoredRGB('{000000}Чистый онлайн за всё время: {279643}'.. print_time(setting.online_stat.total_all))
			else
				imgui.TextColoredRGB('{FFFFFF}Чистый онлайн за всё время: {36CF5C}'.. print_time(setting.online_stat.total_all))
			end
			imgui.PopFont()
			pos_y = pos_y + 81
			
			skin.Button(u8'Сбросить статистику##онлайна', 270, pos_y, 145, 30, function()
				setting.online_stat = {
					clean = {0, 0, 0, 0, 0, 0, 0},
					afk = {0, 0, 0, 0, 0, 0, 0},
					all = {0, 0, 0, 0, 0, 0, 0},
					total_week = 0,
					total_all = 0,
					date_num = {0, 0},
					date_today = {os.date('%d') + 0, os.date('%m') + 0, os.date('%Y') + 0},
					date_last = {os.date('%d') + 0, os.date('%m') + 0, os.date('%Y') + 0},
					date_week = {os.date('%d.%m.%Y'), '', '', '', '', '', ''}
				}
				save('setting')
			end)
			imgui.Dummy(imgui.ImVec2(0, 18))
			
			imgui.EndChild()
		end
		
	----> [8] Музыка
	elseif select_main_menu[8] then
		local function new_draw(pos_draw, par_dr_y)
			imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
		end
		local function draw_button(pos_draw, text_for_draw, num_select)
			imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00)))
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00)))
			end
			imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
			if select_music ~= num_select then
				if imgui.InvisibleButton(u8'##Сменить вкладку музыки'..pos_draw[1], imgui.ImVec2(234, 25)) then select_music = num_select end
				if imgui.IsItemActive() then
					imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.01, col_end.fond_two[2] + 0.01, col_end.fond_two[3] + 0.01, 1.00)))
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00)))
					end
				elseif imgui.IsItemHovered() then
					imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)))
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.08, col_end.fond_two[2] + 0.08, col_end.fond_two[3] + 0.08, 1.00)))
					end
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
			end
			imgui.PushFont(font[1])
			local calc = imgui.CalcTextSize(text_for_draw)
			calc = 117 - (calc.x / 2)
			imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + calc, 43))
			if setting.int.theme == 'White' and num_select == select_music then
				imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), text_for_draw)
			else
				imgui.Text(text_for_draw)
			end
			imgui.PopFont()
		end
		menu_draw_up(u8'Музыка')
		
		draw_button({162, 40}, u8'Поиск в интернете', 1)
		draw_button({396, 40}, u8'Избранные', 2)
		draw_button({630, 40}, u8'Радио Record', 3)
		
		if setting.int.theme == 'White' then
			skin.DrawFond({162, 406 + start_pos + new_pos}, {0, 0}, {702, 58}, imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00), 15, 20)
		else
			skin.DrawFond({162, 406 + start_pos + new_pos}, {0, 0}, {702, 58}, imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00), 15, 20)
		end
		skin.DrawFond({162, 405 + start_pos + new_pos}, {-0.5, 0}, {702, 0.6}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
		
		imgui.PushFont(fa_font[1])
		if status_track_pl == 'STOP' then
			imgui.SetCursorPos(imgui.ImVec2(176, 429 + start_pos + new_pos))
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,0.40), fa.ICON_BACKWARD)
			imgui.SetCursorPos(imgui.ImVec2(245, 429 + start_pos + new_pos))
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,0.40), fa.ICON_FORWARD)
			imgui.PushFont(fa_font[6])
			imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,0.40), fa.ICON_PLAY_CIRCLE_O)
			imgui.PopFont()
		else
			if menu_play_track[1] or menu_play_track[2] then
				imgui.SetCursorPos(imgui.ImVec2(176, 427 + start_pos + new_pos))
				if imgui.InvisibleButton(u8'##Переключить назад', imgui.ImVec2(18, 17)) then back_track() end
				if imgui.IsItemActive() then
					imgui.SetCursorPos(imgui.ImVec2(176, 429 + start_pos + new_pos))
					imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_BACKWARD)
				elseif imgui.IsItemHovered() then
					imgui.SetCursorPos(imgui.ImVec2(176, 429 + start_pos + new_pos))
					imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_BACKWARD)
				else
					imgui.SetCursorPos(imgui.ImVec2(176, 429 + start_pos + new_pos))
					imgui.Text(fa.ICON_BACKWARD)
				end
				
				imgui.SetCursorPos(imgui.ImVec2(243, 427 + start_pos + new_pos))
				if imgui.InvisibleButton(u8'##Переключить вперёд', imgui.ImVec2(18, 17)) then next_track() end
				if imgui.IsItemActive() then
					imgui.SetCursorPos(imgui.ImVec2(245, 429 + start_pos + new_pos))
					imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_FORWARD)
				elseif imgui.IsItemHovered() then
					imgui.SetCursorPos(imgui.ImVec2(245, 429 + start_pos + new_pos))
					imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_FORWARD)
				else
					imgui.SetCursorPos(imgui.ImVec2(245, 429 + start_pos + new_pos))
					imgui.Text(fa.ICON_FORWARD)
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(176, 429 + start_pos + new_pos))
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,0.40), fa.ICON_BACKWARD)
				imgui.SetCursorPos(imgui.ImVec2(245, 429 + start_pos + new_pos))
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,0.40), fa.ICON_FORWARD)
			end
			
			imgui.PushFont(fa_font[6])
			if status_track_pl == 'PLAY' then
				imgui.SetCursorPos(imgui.ImVec2(206, 420 + start_pos + new_pos))
				if imgui.InvisibleButton(u8'##Пауза', imgui.ImVec2(27, 27)) then action_song('PAUSE') end
				if imgui.IsItemActive() then
					imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
					imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_PAUSE_CIRCLE_O)
				elseif imgui.IsItemHovered() then
					imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
					imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_PAUSE_CIRCLE_O)
				else
					imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
					imgui.Text(fa.ICON_PAUSE_CIRCLE_O)
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(206, 420 + start_pos + new_pos))
				if imgui.InvisibleButton(u8'##Возобновить', imgui.ImVec2(27, 27)) then action_song('PLAY') end
				if imgui.IsItemActive() then
					imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
					imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_PLAY_CIRCLE_O)
				elseif imgui.IsItemHovered() then
					imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
					imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_PLAY_CIRCLE_O)
				else
					imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
					imgui.Text(fa.ICON_PLAY_CIRCLE_O)
				end
			end
			imgui.PopFont()
		end
		imgui.PopFont()
		local function thetime()
			if timetr[1] < 10 then
				trt = '0'..timetr[1]
			else
				trt = timetr[1]
			end
			if timetr[2] < 10 then
				trt2 = '0'..timetr[2]
			else
				trt2 = timetr[2]
			end
			return trt2..':'..trt
		end
		imgui.SetCursorPos(imgui.ImVec2(276, 412 + start_pos + new_pos))
		if selectis == status_image then
			imgui.Image(IMG_label, imgui.ImVec2(45, 44))
		elseif select_record == 0 then
			imgui.Image(IMG_No_Label, imgui.ImVec2(45, 44))
		else
			imgui.Image(IMG_Record[select_record], imgui.ImVec2(45, 44))
		end
		imgui.SetCursorPos(imgui.ImVec2(276, 412 + start_pos + new_pos))
		if setting.int.theme == 'White' then
			imgui.Image(IMG_Background_White, imgui.ImVec2(45, 44))
		else
			imgui.Image(IMG_Background, imgui.ImVec2(45, 44))
		end
		imgui.PushFont(font[1])
		if status_track_pl == 'STOP' then
			imgui.SetCursorPos(imgui.ImVec2(336, 420 + start_pos + new_pos))
			imgui.Text(u8'Ничего не воспроизводится')
		else
			local artist_buf = imgui.ImBuffer(58)
			local name_buf = imgui.ImBuffer(58)
			local artist_end = artist
			local name_end = name_tr
			artist_buf.v = artist
			name_buf.v = name_tr
			if artist_buf.v ~= artist then artist_end = artist_buf.v..'...' end
			if name_buf.v ~= name_tr then name_end = name_buf.v..'...' end
			imgui.SetCursorPos(imgui.ImVec2(336, 411 + start_pos + new_pos))
			imgui.Text(u8(artist_end))
			imgui.SetCursorPos(imgui.ImVec2(336, 429 + start_pos + new_pos))
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.70), u8(name_end))
			if select_record == 0 then
				local calc = imgui.CalcTextSize(thetime())
				imgui.SetCursorPos(imgui.ImVec2(736 - calc.x, 433 + start_pos + new_pos))
				imgui.Text(thetime())
			end
		end
		
		imgui.PopFont()
		
		imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(0, 0, 0, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(0, 0, 0, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(0, 0, 0, 0):GetVec4())
		
		imgui.SetCursorPos(imgui.ImVec2(336, 453 + start_pos + new_pos))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 400, p.y + 3), imgui.GetColorU32(imgui.ImVec4(0.50, 0.50, 0.50, 0.40)))
		if status_track_pl ~= 'STOP' then
			if menu_play_track[1] or menu_play_track[2] then
				local size_X_line = (timetr[2] * 60 + timetr[1]) * timetri
				if size_X_line > 400 then
					size_X_line = 400
				end
				imgui.SetCursorPos(imgui.ImVec2(336, 453 + start_pos + new_pos))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + size_X_line, p.y + 3), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
			
				imgui.SetCursorPos(imgui.ImVec2(325, 445 + start_pos + new_pos))
				imgui.PushItemWidth(419)
				if imgui.SliderFloat(u8'##Перемотка', sectime_track, 0, track_time_hc - 2, u8'') then rewind_song(sectime_track.v) end
				if imgui.IsItemHovered() then
					imgui.SetCursorPos(imgui.ImVec2(336 + size_X_line, 454 + start_pos + new_pos))
					local p = imgui.GetCursorScreenPos()
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 6, imgui.GetColorU32(imgui.ImVec4(0.50, 0.50, 0.50 ,1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 6, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 60)
					end
				else
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(336, 453 + start_pos + new_pos))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 400, p.y + 3), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
			end
		end
		imgui.SetCursorPos(imgui.ImVec2(751, 453 + start_pos + new_pos))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 97, p.y + 3), imgui.GetColorU32(imgui.ImVec4(0.50, 0.50, 0.50, 0.40)))
		imgui.SetCursorPos(imgui.ImVec2(751, 453 + start_pos + new_pos))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + (volume_buf.v * 50), p.y + 3), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00)))
		imgui.SetCursorPos(imgui.ImVec2(740, 445 + start_pos + new_pos))
		imgui.PushItemWidth(119)
		if imgui.SliderFloat(u8'##Громкость', volume_buf, 0, 2, u8'') then 
			setting.mus.volume = volume_buf.v 
			save('setting')
			volume_song(setting.mus.volume)
		end
		volume_buf.v = setting.mus.volume
		imgui.PopStyleColor(3)
		imgui.SetCursorPos(imgui.ImVec2(751 + (volume_buf.v * 48), 454 + start_pos + new_pos))
		local p = imgui.GetCursorScreenPos()
		if setting.int.theme == 'White' then
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 6, imgui.GetColorU32(imgui.ImVec4(0.50, 0.50, 0.50 ,1.00)), 60)
		else
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 6, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 60)
		end
		
		imgui.PushFont(fa_font[4])
		imgui.SetCursorPos(imgui.ImVec2(748, 419 + start_pos + new_pos))
		if imgui.InvisibleButton(u8'##Повторение', imgui.ImVec2(20, 20)) then setting.mus.rep = not setting.mus.rep save('setting') end
		imgui.SetCursorPos(imgui.ImVec2(751, 421 + start_pos + new_pos))
		if setting.mus.rep and not imgui.IsItemActive() then
			imgui.Text(fa.ICON_REPEAT)
		elseif not imgui.IsItemActive() then
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.40), fa.ICON_REPEAT)
		elseif imgui.IsItemActive() then
			imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_REPEAT)
		end
		imgui.SetCursorPos(imgui.ImVec2(789, 419 + start_pos + new_pos))
		if imgui.InvisibleButton(u8'##Окно плеера', imgui.ImVec2(20, 20)) then setting.mus.win = not setting.mus.win save('setting') end
		imgui.SetCursorPos(imgui.ImVec2(792, 421 + start_pos + new_pos))
		if setting.mus.win and not imgui.IsItemActive() then
			imgui.Text(fa.ICON_WINDOW_MAXIMIZE)
		elseif not imgui.IsItemActive() then
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.40), fa.ICON_WINDOW_MAXIMIZE)
		elseif imgui.IsItemActive() then
			imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_WINDOW_MAXIMIZE)
		end
		imgui.SetCursorPos(imgui.ImVec2(832, 419 + start_pos + new_pos))
		if imgui.InvisibleButton(u8'##Остановить музыку', imgui.ImVec2(20, 20)) then
			action_song('STOP')
			sel_link = ''
		end
		imgui.SetCursorPos(imgui.ImVec2(835, 421 + start_pos + new_pos))
		if not imgui.IsItemActive() then
			imgui.Text(fa.ICON_STOP)
		else
			imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_STOP)
		end
		imgui.PopFont()
		
		if select_music == 1 then
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(162, 65))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 702, p.y + 36), imgui.GetColorU32(imgui.ImVec4(0.78, 0.78, 0.78, 1.00)))
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 702, p.y + 36), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30, 1.00)))
			end
			
			if skin.InputText(193, 72, u8'Введите название песни или его исполнителя', 'text_find_track', 100, 591, nil, nil, 'enterflag') then
				if text_find_track ~= '' then
					qua_page = 1
					sel_link = ''
					find_track_link(text_find_track, 1)
				end
			end
			imgui.PushFont(fa_font[4])
			imgui.SetCursorPos(imgui.ImVec2(176, 73))
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), fa.ICON_SEARCH)
			imgui.PopFont()
			
			imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 0)
			skin.Button(u8'Поиск', 784, 65, 80, 36, function() 
				if text_find_track ~= '' then
					qua_page = 1
					sel_link = ''
					find_track_link(text_find_track, 1)
				end
			end)
			imgui.PopStyleVar(1)
			imgui.SetCursorPos(imgui.ImVec2(180, 101))
			imgui.BeginChild(u8'Поиск в интернете', imgui.ImVec2(682, 304 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			
			if tracks.link[1] ~= 'Ошибка404' then
				local POS_Y_T = 17
				for i = 1, #tracks.link do
					new_draw(POS_Y_T, 36)
					imgui.SetCursorPos(imgui.ImVec2(32, POS_Y_T))
					if imgui.InvisibleButton(u8'##Включить трек'..i, imgui.ImVec2(634, 36)) then
						if menu_play_track[1] and selectis == i and sel_link == tracks.link[i] then
							if status_track_pl == 'PLAY' then
								action_song('PAUSE')
							elseif status_track_pl == 'PAUSE' then
								action_song('PLAY')
							end
						elseif selectis ~= i and menu_play_track[1] or not menu_play_track[1] or sel_link ~= tracks.link[i] then
							selectis = i
							sel_link = tracks.link[i]
							select_record = 0
							menu_play_track = {true, false, false}
							play_song(tracks.link[selectis], false)
						end
					end
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(0, POS_Y_T))
						local p = imgui.GetCursorScreenPos()
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.02, col_end.fond_two[2] + 0.02, col_end.fond_two[3] + 0.02, 1.00)), 8, 15)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00)), 8, 15)
						end
					elseif imgui.IsItemHovered() then
						imgui.SetCursorPos(imgui.ImVec2(0, POS_Y_T))
						local p = imgui.GetCursorScreenPos()
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.04, col_end.fond_two[2] + 0.04, col_end.fond_two[3] + 0.04, 1.00)), 8, 15)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.12, col_end.fond_two[2] + 0.12, col_end.fond_two[3] + 0.12, 1.00)), 8, 15)
						end
					else
						if menu_play_track[1] and selectis == i and sel_link == tracks.link[i] then
							imgui.SetCursorPos(imgui.ImVec2(0, POS_Y_T))
							local p = imgui.GetCursorScreenPos()
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.07, col_end.fond_two[2] - 0.07, col_end.fond_two[3] - 0.07, 1.00)), 8, 15)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.16, col_end.fond_two[2] + 0.16, col_end.fond_two[3] + 0.16, 1.00)), 8, 15)
							end
						end
					end
					
					imgui.PushFont(fa_font[4])
					local favorite_track = false
					local favorite_track_i = 1
					if #save_tracks.link ~= 0 then
						for k = 1, #save_tracks.link do
							if tracks.link[i] == save_tracks.link[k] then 
								favorite_track = true
								favorite_track_i = k
								break
							end
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(7, POS_Y_T + 8))
					if imgui.InvisibleButton(u8'##Добавить в избранные'..i, imgui.ImVec2(20, 20)) then
						if favorite_track then
							table.remove(save_tracks.link, favorite_track_i)
							table.remove(save_tracks.artist, favorite_track_i)
							table.remove(save_tracks.name, favorite_track_i)
							table.remove(save_tracks.time, favorite_track_i)
							table.remove(save_tracks.image, favorite_track_i)
							save('save_tracks')
							if selectis ~= 0 and menu_play_track[2] then
								if favorite_track_i <= selectis and selectis ~= 1 and favorite_track_i ~= selectis and #save_tracks.link ~= 0 then
									selectis = selectis - 1
									status_image = selectis
								elseif favorite_track_i == #save_tracks.link+1 and selectis == favorite_track_i and #save_tracks.link ~= 0 then
									selectis = selectis - 1
									play_song(save_tracks.link[selectis], false)
								elseif favorite_track_i == selectis and favorite_track_i ~= #save_tracks.link + 1 and #save_tracks.link ~= 0 then
									play_song(save_tracks.link[selectis], false)
								end
								if #save_tracks.link == 0 then
									action_song('STOP')
								end
							end
						else
							table.insert(save_tracks.link, 1, tracks.link[i])
							table.insert(save_tracks.artist, 1, tracks.artist[i])
							table.insert(save_tracks.name, 1, tracks.name[i])
							table.insert(save_tracks.time, 1, tracks.time[i])
							table.insert(save_tracks.image, 1, tracks.image[i])
							save('save_tracks')
							if selectis ~= 0 and status_track_pl ~= 'STOP' and menu_play_track[2] then
								selectis = selectis + 1
								status_image = status_image + 1
							end
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(11, POS_Y_T + 10))
					if imgui.IsItemActive() then
						if not favorite_track then
							imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_PLUS)
						else
							imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_CHECK)
						end
					elseif imgui.IsItemHovered() then
						if not favorite_track then
							imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_PLUS)
						else
							imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_CHECK)
						end
					else
						if not favorite_track then
							imgui.Text(fa.ICON_PLUS)
						else
							imgui.Text(fa.ICON_CHECK)
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(35, POS_Y_T + 10))
					if selectis ~= i and sel_link ~= tracks.link[i] then
						imgui.Text(fa.ICON_PLAY)
					elseif status_track_pl == 'PLAY' and menu_play_track[1] and sel_link == tracks.link[i] then
						imgui.Text(fa.ICON_PAUSE)
					elseif status_track_pl == 'PAUSE' and menu_play_track[1] and sel_link == tracks.link[i] or not menu_play_track[1] or sel_link ~= tracks.link[i] then
						imgui.Text(fa.ICON_PLAY)
					end
					imgui.PopFont()
					imgui.PushFont(font[1])
					local track_text = tracks.artist[i]..' {7f7f7f}- '..tracks.name[i]
					local buf_size_text = imgui.ImBuffer(85)
					buf_size_text.v = track_text
					if buf_size_text.v ~= track_text then buf_size_text.v = string.sub(buf_size_text.v, 1, -4) .. '...' end
					imgui.SetCursorPos(imgui.ImVec2(58, POS_Y_T + 9))
					if setting.int.theme == 'White' then
						imgui.TextColoredRGB('{000000}'..buf_size_text.v)
					else
						imgui.TextColoredRGB(buf_size_text.v)
					end
					local calc = imgui.CalcTextSize(tracks.time[i])
					imgui.SetCursorPos(imgui.ImVec2(656 - calc.x, POS_Y_T + 9))
					imgui.Text(tracks.time[i])
					imgui.PopFont()
					POS_Y_T = POS_Y_T + 46
				end
				imgui.Dummy(imgui.ImVec2(0, 20))
				
				if qua_page ~= 1 then
					local imvec4_col = imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00))
					if setting.int.theme == 'White' then
						imvec4_col = imgui.GetColorU32(imgui.ImVec4(0.80, 0.80, 0.80 ,1.00))
					end
					local pos_page = 315
					if qua_page == 3 then
						pos_page = 297
					elseif qua_page == 4 then
						pos_page = 279
					end
					for m = 1, qua_page do
						imgui.SetCursorPos(imgui.ImVec2(pos_page, POS_Y_T + 20))
						local p = imgui.GetCursorScreenPos()
						imgui.SetCursorPos(imgui.ImVec2(pos_page - 11, POS_Y_T + 9))
						if m == current_page then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.5, p.y - 0.5), 11, imvec4_col, 60)
						end
						if imgui.InvisibleButton(u8'##Перейти к странице'..m, imgui.ImVec2(23, 23)) then
							find_track_link(text_find_track, m)
							current_page = m
						end
						imgui.SetCursorPos(imgui.ImVec2(pos_page - 3, POS_Y_T + 11))
						imgui.PushFont(font[1])
						imgui.Text(tostring(m))
						imgui.PopFont()
						pos_page = pos_page + 36
					end
					imgui.Dummy(imgui.ImVec2(0, 13))
				end
			else
				imgui.PushFont(bold_font[4])
				imgui.SetCursorPos(imgui.ImVec2(172, 128 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'Ничего не найдено')
				imgui.PopFont()
			end
			imgui.EndChild()
			imgui.PopFont()
			
		elseif select_music == 2 then
			imgui.SetCursorPos(imgui.ImVec2(180, 65))
			imgui.BeginChild(u8'Избранные', imgui.ImVec2(682, 340 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			
			local remove_table_track = nil
			if #save_tracks.link ~= 0 then
				local POS_Y_T = 17
				for i = 1, #save_tracks.link do
					new_draw(POS_Y_T, 36)
					imgui.SetCursorPos(imgui.ImVec2(32, POS_Y_T))
					if imgui.InvisibleButton(u8'##Включить сохранённый трек'..i, imgui.ImVec2(634, 36)) then
						if menu_play_track[2] and selectis == i then
							if status_track_pl == 'PLAY' then
								action_song('PAUSE')
							elseif status_track_pl == 'PAUSE' then
								action_song('PLAY')
							end
						elseif selectis ~= i and menu_play_track[2] or not menu_play_track[2] then
							selectis = i
							select_record = 0
							menu_play_track = {false, true, false}
							play_song(save_tracks.link[selectis], false)
						end
					end
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(0, POS_Y_T))
						local p = imgui.GetCursorScreenPos()
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.02, col_end.fond_two[2] + 0.02, col_end.fond_two[3] + 0.02, 1.00)), 8, 15)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00)), 8, 15)
						end
					elseif imgui.IsItemHovered() then
						imgui.SetCursorPos(imgui.ImVec2(0, POS_Y_T))
						local p = imgui.GetCursorScreenPos()
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.04, col_end.fond_two[2] + 0.04, col_end.fond_two[3] + 0.04, 1.00)), 8, 15)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.12, col_end.fond_two[2] + 0.12, col_end.fond_two[3] + 0.12, 1.00)), 8, 15)
						end
					else
						if menu_play_track[2] and selectis == i then
							imgui.SetCursorPos(imgui.ImVec2(0, POS_Y_T))
							local p = imgui.GetCursorScreenPos()
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.07, col_end.fond_two[2] - 0.07, col_end.fond_two[3] - 0.07, 1.00)), 8, 15)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.16, col_end.fond_two[2] + 0.16, col_end.fond_two[3] + 0.16, 1.00)), 8, 15)
							end
						end
					end
					
					imgui.PushFont(fa_font[4])
					imgui.SetCursorPos(imgui.ImVec2(7, POS_Y_T + 8))
					if imgui.InvisibleButton(u8'##Удалить из избранных'..i, imgui.ImVec2(20, 20)) then
						remove_table_track = i
					end
					imgui.SetCursorPos(imgui.ImVec2(11, POS_Y_T + 10))
					if imgui.IsItemActive() then
						imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_TRASH)
					elseif imgui.IsItemHovered() then
						imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_TRASH)
					else
						imgui.Text(fa.ICON_TRASH)
					end
					imgui.SetCursorPos(imgui.ImVec2(35, POS_Y_T + 10))
					if selectis ~= i then
						imgui.Text(fa.ICON_PLAY)
					elseif status_track_pl == 'PLAY' and menu_play_track[2] then
						imgui.Text(fa.ICON_PAUSE)
					elseif status_track_pl == 'PAUSE' and menu_play_track[2] or not menu_play_track[2] then
						imgui.Text(fa.ICON_PLAY)
					end
					imgui.PopFont()
					imgui.PushFont(font[1])
					local track_text = save_tracks.artist[i]..' {7f7f7f}- '..save_tracks.name[i]
					local buf_size_text = imgui.ImBuffer(85)
					buf_size_text.v = track_text
					if buf_size_text.v ~= track_text then buf_size_text.v = string.sub(buf_size_text.v, 1, -4) .. '...' end
					imgui.SetCursorPos(imgui.ImVec2(58, POS_Y_T + 9))
					if setting.int.theme == 'White' then
						imgui.TextColoredRGB('{000000}'..buf_size_text.v)
					else
						imgui.TextColoredRGB(buf_size_text.v)
					end
					local calc = imgui.CalcTextSize(save_tracks.time[i])
					imgui.SetCursorPos(imgui.ImVec2(656 - calc.x, POS_Y_T + 9))
					imgui.Text(save_tracks.time[i])
					imgui.PopFont()
					POS_Y_T = POS_Y_T + 46
				end
				imgui.Dummy(imgui.ImVec2(0, 20))
			else
				imgui.PushFont(bold_font[4])
				imgui.SetCursorPos(imgui.ImVec2(145, 146 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'Нет избранных треков')
				imgui.PopFont()
			end
			
			if remove_table_track ~= nil then
				local i = remove_table_track
				table.remove(save_tracks.link, i)
				table.remove(save_tracks.artist, i)
				table.remove(save_tracks.name, i)
				table.remove(save_tracks.time, i)
				table.remove(save_tracks.image, i)
				save('save_tracks')
				if selectis ~= 0 and menu_play_track[2] then
					if i <= selectis and selectis ~= 1 and i ~= selectis and #save_tracks.link ~= 0 then
						selectis = selectis - 1
						status_image = selectis
					elseif i == #save_tracks.link+1 and selectis == i and #save_tracks.link ~= 0 then
						selectis = selectis - 1
						play_song(save_tracks.link[selectis], false)
					elseif i == selectis and i ~= #save_tracks.link + 1 and #save_tracks.link ~= 0 then
						play_song(save_tracks.link[selectis], false)
					end
					if #save_tracks.link == 0 then
						action_song('STOP')
						selectis = 0
					end
				end
			end
			
			imgui.EndChild()
		elseif select_music == 3 then
			imgui.SetCursorPos(imgui.ImVec2(162, 65))
			imgui.BeginChild(u8'Радио Record', imgui.ImVec2(702, 340 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			
			local function background_record_card(posX_R, posY_R, i_R, record_text_name)
				imgui.SetCursorPos(imgui.ImVec2(posX_R, posY_R))
				if imgui.InvisibleButton(u8'##Включить радиостанцию'..i_R, imgui.ImVec2(126, 156)) then 
					selectis = 0
					menu_play_track = {false, false, true}
					if select_record ~= i_R then
						select_record = i_R
						artist = 'Record'
						name_tr = record_name[i_R]
						play_song(record[i_R])
					elseif status_track_pl == 'PLAY' then
						action_song('PAUSE')
					elseif status_track_pl == 'PAUSE' then
						action_song('PLAY')
					end
				end
				if select_record ~= i_R then
					if imgui.IsItemActive() then
					
						if setting.int.theme == 'White' then
							skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] - 0.03, col_end.fond_two[2] - 0.03, col_end.fond_two[3] - 0.03, 1.00), 8, 15)
						else
							skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00), 8, 15)
						end
					elseif imgui.IsItemHovered() then
						if setting.int.theme == 'White' then
							skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] + 0.02, col_end.fond_two[2] + 0.02, col_end.fond_two[3] + 0.02, 1.00), 8, 15)
						else
							skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] + 0.12, col_end.fond_two[2] + 0.12, col_end.fond_two[3] + 0.12, 1.00), 8, 15)
						end
					else
						if setting.int.theme == 'White' then
							skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00), 8, 15)
						else
							skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00), 8, 15)
						end
					end
				else
					if setting.int.theme == 'White' then
						skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(0.99, 0.35, 0.12 ,0.90), 8, 15)
					else
						skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(0.99, 0.35, 0.12 ,0.90), 8, 15)
					end
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(posX_R + 16, posY_R + 5))
				imgui.Image(IMG_Record[i_R], imgui.ImVec2(94, 94))
				local calc = imgui.CalcTextSize(u8(record_text_name))
				imgui.SetCursorPos(imgui.ImVec2(posX_R + (63 - calc.x / 2 ), posY_R + 114))
				imgui.Text(u8(record_text_name))
				imgui.PopFont()
			end
			
			background_record_card(12, 12 + ((start_pos + new_pos) / 2), 1, 'Record')
			background_record_card(150, 12 + ((start_pos + new_pos) / 2), 2, 'Megamix')
			background_record_card(288, 12 + ((start_pos + new_pos) / 2), 3, 'Party 24/7')
			background_record_card(426, 12 + ((start_pos + new_pos) / 2), 4, 'Phonk')
			background_record_card(564, 12 + ((start_pos + new_pos) / 2), 5, 'Гоп FM')
			
			background_record_card(12, 176 + ((start_pos + new_pos) / 2), 6, 'Руки Вверх')
			background_record_card(150, 176 + ((start_pos + new_pos) / 2), 7, 'Dupstep')
			background_record_card(288, 176 + ((start_pos + new_pos) / 2), 8, 'Big Hits')
			background_record_card(426, 176 + ((start_pos + new_pos) / 2), 9, 'Organic')
			background_record_card(564, 176 + ((start_pos + new_pos) / 2), 10, 'Russian Hits')
			
			imgui.EndChild()
		end
		
	----> [9] РП зона
	elseif select_main_menu[9] then
		local function new_draw(pos_draw, par_dr_y)
			imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
		end
		
		menu_draw_up(u8'РП зона')
		imgui.SetCursorPos(imgui.ImVec2(180, 41))
		imgui.BeginChild(u8'РП зона', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
		
		if select_scene == 0 then
			if not setting.rp_zone then
				imgui.PushFont(font[4])
				imgui.SetCursorPos(imgui.ImVec2(93, 155 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'Здесь Вы можете создать Role Play SS для Вашего отчёта')
				imgui.SetCursorPos(imgui.ImVec2(168, 185 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'прямо в игре без сторонних программ!')
				imgui.PopFont()
				imgui.PushFont(font[1])
				skin.Button(u8'Начать', 270, 225 + ((start_pos + new_pos) / 2), 125, 35, function()
					setting.rp_zone = true
					save('setting')
				end)
				imgui.PopFont()
			else
				if #scene.bq == 0 then
					imgui.PushFont(bold_font[4])
					imgui.SetCursorPos(imgui.ImVec2(258, 159 + ((start_pos + new_pos) / 2)))
					imgui.Text(u8'Нет сцен')
					imgui.PopFont()
					imgui.PushFont(font[1])
					skin.Button(u8'Добавить сцену', 270, 212 + ((start_pos + new_pos) / 2), 125, 35, function()
						local new_scene = {
							nm = u8'Сцена '..(#scene + 1),
							pos = {x = 20, y = 20},
							size = 13,
							dist = 21,
							vis = 255,
							flag = 5,
							invers = false,
							qq = {}
						}
						table.insert(scene.bq, new_scene)
						col_sc = {}
						save('scene')
						scene_buf = new_scene
						font_sc = renderCreateFont('Arial', scene_buf.size, scene_buf.flag)
						select_scene = #scene.bq
						edit_sc = true
					end)
					imgui.PopFont()
				else
					new_draw(17, -1 + (#scene.bq * 68))
					imgui.PushFont(font[1])
					for i = 1, #scene.bq do
						imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
						if imgui.InvisibleButton(u8'##Перейти в редактор сцены'..i, imgui.ImVec2(666, 68)) then 
							POS_Y = 380
							col_sc = {}
							if scene.bq[i].qq ~= 0 then
								for m = 1, #scene.bq[i].qq do
									table.insert(col_sc, convert_color(scene.bq[i].qq[m].color))
								end
							end
							scene_buf = scene.bq[i]
							font_sc = renderCreateFont('Arial', scene_buf.size, scene_buf.flag)
							select_scene = i
							edit_sc = true
						end
						imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
						local p = imgui.GetCursorScreenPos()
						if imgui.IsItemActive() then
							if i == 1 and #scene.bq ~= 1 then
								if setting.int.theme == 'White' then
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 3)
								else
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 3)
								end
							elseif i == 1 and #scene.bq == 1 then
								if setting.int.theme == 'White' then
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 15)
								else
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 15)
								end 
							elseif i == #scene.bq then
								if setting.int.theme == 'White' then
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 12)
								else
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 12)
								end
							else
								if setting.int.theme == 'White' then
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 0)
								else
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 0)
								end
							end
						end
						imgui.PushFont(fa_font[5])
						imgui.SetCursorPos(imgui.ImVec2(640, 37 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
						imgui.Text(fa.ICON_ANGLE_RIGHT)
						imgui.PopStyleColor(1)
						imgui.PopFont()
						
						imgui.SetCursorPos(imgui.ImVec2(17, 41 + ( (i - 1) * 68)))
						imgui.Text(scene.bq[i].nm)
					end
					if #scene.bq > 1 then
						for draw = 1, #scene.bq - 1 do
							skin.DrawFond({17, 16 + (draw * 68)}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
						end
					end
					skin.Button(u8'Добавить сцену', 270, 34 + (#scene.bq * 68), 125, 35, function()
						local new_scene = {
							nm = u8'Сцена '..(#scene + 1),
							pos = {x = 20, y = 20},
							size = 13,
							dist = 21,
							vis = 255,
							flag = 5,
							invers = false,
							qq = {}
						}
						table.insert(scene.bq, new_scene)
						col_sc = {}
						save('scene')
						scene_buf = new_scene
						select_scene = #scene.bq
						edit_sc = true
					end)
					imgui.PopFont()
				end
				imgui.Dummy(imgui.ImVec2(0, 20))
			end
		else
			imgui.PushFont(font[1])
			new_draw(17, 84)
			skin.Button(u8'Сохранить сцену', 15, 29, 202, 30, function() 
				scene.bq[select_scene] = scene_buf
				save('scene')
				select_scene = 0
				edit_sc = false
			end)
			skin.Button(u8'Удалить сцену', 232, 29, 202, 30, function()
				table.remove(scene.bq, select_scene)
				save('scene')
				select_scene = 0
				edit_sc = false
			end)
			skin.Button(u8'Включить сцену', 449, 29, 202, 30, function()
				scene_active = true
				scene_edit_i = false
				win.main.v = false
				imgui.ShowCursor = false
				displayRadar(false)
				displayHud(false)
				lockPlayerControl(true)
				posX, posY, posZ = getCharCoordinates(playerPed)
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
				angZ = getCharHeading(playerPed)
				angZ = angZ * -1.0
				angY = 0.0
			end)
			imgui.SetCursorPos(imgui.ImVec2(15, 73))
			imgui.Text(u8'Предосмотр')
			imgui.SetCursorPos(imgui.ImVec2(620, 72))
			if skin.Switch(u8'##Предосмотр', preview_sc) then preview_sc = not preview_sc end
			
			new_draw(113, 50)
			skin.InputText(15, 127, u8'Задайте имя сцены', 'scene_buf.nm', 80, 636)
			
			new_draw(175, 213)
			if skin.Slider('##Размер шрифта', 'scene_buf.size', 1, 30, 205, {455, 186}, '') then font_sc = renderCreateFont('Arial', scene_buf.size, scene_buf.flag) end
			if skin.Slider('##Флаг шрифта', 'scene_buf.flag', 1, 30, 205, {455, 217}, '') then font_sc = renderCreateFont('Arial', scene_buf.size, scene_buf.flag) end
			skin.Slider('##Расстояние между строками', 'scene_buf.dist', 1, 40, 205, {455, 247})
			skin.Slider('##Прозрачность текста', 'scene_buf.vis', 1, 255, 205, {455, 277})
			imgui.SetCursorPos(imgui.ImVec2(620, 309))
			if skin.Switch(u8'##Инверсировать текст', scene_buf.invers) then scene_buf.invers = not scene_buf.invers end
			imgui.SetCursorPos(imgui.ImVec2(15, 188))
			imgui.Text(u8'Размер шрифта')
			imgui.SetCursorPos(imgui.ImVec2(15, 219))
			imgui.Text(u8'Флаг шрифта')
			imgui.SetCursorPos(imgui.ImVec2(15, 249))
			imgui.Text(u8'Расстояние между строками')
			imgui.SetCursorPos(imgui.ImVec2(15, 279))
			imgui.Text(u8'Прозрачность текста')
			imgui.SetCursorPos(imgui.ImVec2(15, 310))
			imgui.Text(u8'Инверсировать текст')
			skin.Button(u8'Изменить положение текста', 15, 346, 636, 30, function() scene_edit() end)
			
			local pos_X_sc = 470
			imgui.PushFont(bold_font[4])
			imgui.SetCursorPos(imgui.ImVec2(243, pos_X_sc - 58))
			imgui.Text(u8'Отыгровки')
			imgui.PopFont()
			new_draw(pos_X_sc - 12, 58 + (#scene_buf.qq * 95))
			skin.Button(u8'Добавить отыгровку', 238, pos_X_sc + (#scene_buf.qq * 95), 202, 30, function() 
				table.insert(scene_buf.qq, {
					text = '',
					act = '',
					type_color = u8'Свой текст и цвет',
					nm = sampGetPlayerNickname(my.id),
					color = 0xFFFFFFFF
				})
				table.insert(col_sc, convert_color(scene_buf.qq[#scene_buf.qq].color))
			end)
			
			local remove_table_qq = nil
			for i = 1, #scene_buf.qq do
				local pos_Y_scene = pos_X_sc + ((i - 1) * 95)
				if scene_buf.qq[i].type_color ~= u8'/todo' then
					skin.InputText(15, pos_Y_scene, u8'Текст отыгровки##'..i, 'scene_buf.qq.'..i..'.text', 300, 595)
				else
					skin.InputText(15, pos_Y_scene, u8'Текст речи##'..i, 'scene_buf.qq.'..i..'.text', 300, 290)
					skin.InputText(320, pos_Y_scene, u8'Текст отыгровки##'..i, 'scene_buf.qq.'..i..'.act', 300, 290)
				end
				local scroll_bool = false
				if skin.List({15, pos_Y_scene + 35}, scene_buf.qq[i].type_color, {u8'Свой текст и цвет', u8'/me', u8'/do', u8'/todo', u8'Речь'}, 200, 'scene_buf.qq.'..i..'.type_color', '') then
				end
				if scene_buf.qq[i].type_color == u8'Свой текст и цвет' then
					imgui.SetCursorPos(imgui.ImVec2(230, pos_Y_scene + 41))
					imgui.Text(u8'Цвет')
					imgui.SetCursorPos(imgui.ImVec2(270, pos_Y_scene + 40))
					if imgui.ColorEdit4('##Color'..i, col_sc[i], imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
						local c = imgui.ImVec4(col_sc[i].v[1], col_sc[i].v[2], col_sc[i].v[3], col_sc[i].v[4])
						local argb = imgui.ColorConvertFloat4ToARGB(c)
						scene_buf.qq[i].color = imgui.ColorConvertFloat4ToARGB(c)
					end
				else
					imgui.SetCursorPos(imgui.ImVec2(230, pos_Y_scene + 41))
					imgui.Text(u8'Имя персонажа')
					skin.InputText(340, pos_Y_scene + 39, u8'Имя персонажа##'..i, 'scene_buf.qq.'..i..'.nm', 150, 270)
				end
				imgui.SetCursorPos(imgui.ImVec2(632, pos_Y_scene - 1))
				if imgui.InvisibleButton(u8'##Удалить'..i, imgui.ImVec2(22, 22)) then remove_table_qq = i end
				imgui.PushFont(fa_font[1])
				imgui.SetCursorPos(imgui.ImVec2(636, pos_Y_scene + 4))
				imgui.Text(fa.ICON_TRASH)
				imgui.PopFont()
				
				skin.DrawFond({17, pos_Y_scene + 78}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			end
			if remove_table_qq ~= nil then table.remove(scene_buf.qq, remove_table_qq) end
			imgui.PopFont()
			if #scene_buf.qq ~= 0 then
				imgui.Dummy(imgui.ImVec2(0, 76))
			else
				imgui.Dummy(imgui.ImVec2(0, 30))
			end
			
		end
		
		imgui.EndChild()
	
	----> [11] Лекционная
	elseif select_main_menu[11] and select_lec == 0 then
		local function new_draw(pos_draw, par_dr_y)
			imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
		end
		
		menu_draw_up(u8'Лекционная')
		
		imgui.PushFont(fa_font[1])
		imgui.SetCursorPos(imgui.ImVec2(826, 11))
		imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 4)
		if imgui.Button(u8'##Добавить лекцию', imgui.ImVec2(22, 22)) then
			lec_buf = {
				q = {},
				wait = 2000,
				cmd = ''
			}
			select_lec = #setting.lec + 1
		end
		imgui.PopStyleVar(1)
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(255, 255, 255, 255):GetVec4())
		imgui.SetCursorPos(imgui.ImVec2(830, 17))
		imgui.Text(fa.ICON_PLUS)
		imgui.PopStyleColor(1)
		imgui.PopFont()
		imgui.SetCursorPos(imgui.ImVec2(180, 41))
		
		imgui.BeginChild(u8'Лекционная', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
		if #setting.lec == 0 then
			imgui.PushFont(bold_font[4])
			imgui.SetCursorPos(imgui.ImVec2(154, 187 + ((start_pos + new_pos) / 2)))
			imgui.Text(u8'Нет ни одной лекции')
			imgui.PopFont()
		else
			new_draw(17, -1 + (#setting.lec * 68))
			imgui.PushFont(font[1])
			local remove_lec
			for i = 1, #setting.lec do
				imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
				if imgui.InvisibleButton(u8'##Перейти в редактор лекции'..i, imgui.ImVec2(666, 68)) then 
					local function deepCopy(orig)
						local copy
							if type(orig) == 'table' then
							copy = {}
							for key, value in next, orig, nil do
								copy[deepCopy(key)] = deepCopy(value)
							end
							setmetatable(copy, deepCopy(getmetatable(orig)))
						else
							copy = orig
						end
						
						return copy
					end
					lec_buf = deepCopy(setting.lec[i])
					select_lec = i
				end
				imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemActive() then
					if i == 1 and #setting.lec ~= 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 3)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 3)
						end
					elseif i == 1 and #setting.lec == 1 then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 15)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 15)
						end 
					elseif i == #setting.lec then
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 12)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 12)
						end
					else
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 8, 0)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 8, 0)
						end
					end
				end
				imgui.PushFont(fa_font[5])
				imgui.SetCursorPos(imgui.ImVec2(640, 37 + ( (i - 1) * 68)))
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
				imgui.Text(fa.ICON_ANGLE_RIGHT)
				imgui.PopStyleColor(1)
				imgui.PopFont()
				
				imgui.SetCursorPos(imgui.ImVec2(17, 39 + ( (i - 1) * 68)))
				imgui.Text('/'..setting.lec[i].cmd)
			end
			if remove_lec ~= nil then table.remove(setting.lec, remove_lec) save('setting') end
			if #setting.lec > 1 then
				for draw = 1, #setting.lec - 1 do
					skin.DrawFond({17, 16 + (draw * 68)}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
				end
			end
			imgui.PopFont()
		end
		imgui.Dummy(imgui.ImVec2(0, 80))
		imgui.EndChild()
	elseif select_main_menu[11] and select_lec ~= 0 then
		local function new_draw(pos_draw, par_dr_y, sizes_if_win, comm_tr)
			if sizes_if_win == nil then
				sizes_if_win = {17, 666}
			end
			imgui.SetCursorPos(imgui.ImVec2(sizes_if_win[1], pos_draw))
			local p = imgui.GetCursorScreenPos()
			if comm_tr == nil then
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
				end
			else
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(0.99, 1.00, 0.21, 0.50)), 8, 15)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(0.99, 1.00, 0.21, 0.30)), 8, 15)
				end
			end
		end
		
		if menu_draw_up(u8'Редактирование лекции', true) then
			imgui.OpenPopup(u8'Дальнейшие действия с лекцией')
			lec_err_nm = false
			lec_err_fact = false
		end
		if imgui.BeginPopupModal(u8'Дальнейшие действия с лекцией', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.BeginChild(u8'Действие с лекцией', imgui.ImVec2(400, 200), false, imgui.WindowFlags.NoScrollbar)
			imgui.SetCursorPos(imgui.ImVec2(0, 0))
			if imgui.InvisibleButton(u8'##Закрыть окошко лекции', imgui.ImVec2(20, 20)) then
				imgui.CloseCurrentPopup()
			end
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			local p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
				imgui.SetCursorPos(imgui.ImVec2(6, 3))
				imgui.PushFont(fa_font[2])
				imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
			end
			
			imgui.PushFont(bold_font[4])
			if not lec_err_nm and not lec_err_fact then
				imgui.SetCursorPos(imgui.ImVec2(35, 55))
				imgui.Text(u8'Выберите действие')
			elseif not lec_err_fact then
				imgui.SetCursorPos(imgui.ImVec2(127, 39))
				imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'ОШИБКА')
				
				imgui.PushFont(font[4])
				imgui.SetCursorPos(imgui.ImVec2(63, 95))
				imgui.Text(u8'Такая команда уже существует!')
				imgui.PopFont()
			elseif not lec_err_nm then
				imgui.SetCursorPos(imgui.ImVec2(127, 39))
				imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'ОШИБКА')
				
				imgui.PushFont(font[4])
				imgui.SetCursorPos(imgui.ImVec2(126, 95))
				imgui.Text(u8'Задайте команду!')
				imgui.PopFont()
			end
			imgui.PopFont()
			imgui.PushFont(font[1])
			skin.Button(u8'Сохранить##команду', 10, 167, 123, 25, function()
				if lec_buf.cmd == 'sh' or lec_buf.cmd == 'ts' then lec_err_nm = true end
				for i = 1, #setting.cmd do
					if setting.cmd[i][1] == lec_buf.cmd then
						lec_err_nm = true
						break
					end
				end
				for i = 1, #setting.lec do
					if setting.lec[i].cmd == lec_buf.cmd and i ~= select_lec then
						lec_err_nm = true
						break
					end
				end
				if lec_buf.cmd == '' then lec_err_fact = true end
				if not lec_err_nm and not lec_err_fact then
					if setting.lec[select_lec] ~= nil then
						sampUnregisterChatCommand(setting.lec[select_lec].cmd)
						sampRegisterChatCommand(lec_buf.cmd, function(arg) lec_start(arg, lec_buf.cmd) end)
						setting.lec[select_lec] = lec_buf
					else
						sampRegisterChatCommand(lec_buf.cmd, function(arg) lec_start(arg, lec_buf.cmd) end)
						setting.lec[select_lec] = lec_buf
					end
					save('setting')
					select_lec = 0
					imgui.CloseCurrentPopup()
				end
			end)
			skin.Button(u8'Не сохранять', 138, 167, 124, 25, function()
				select_lec = 0
				imgui.CloseCurrentPopup()
			end)
			skin.Button(u8'Удалить', 267, 167, 123, 25, function()
				if setting.lec[select_lec] ~= nil then
					table.remove(setting.lec, select_lec)
				end
				save('setting')
				select_lec = 0
				imgui.CloseCurrentPopup()
			end)
			imgui.PopFont()
			imgui.EndChild()
			imgui.EndPopup()
		end
		
		if select_lec ~= 0 then
			imgui.SetCursorPos(imgui.ImVec2(163, 41))
			imgui.BeginChild(u8'Редактирование лекции', imgui.ImVec2(700, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			
			new_draw(17, 50)
			imgui.PushFont(font[1])
			skin.InputText(114, 31, u8'Установите команду', 'lec_buf.cmd', 15, 553, '[%a%d+-]+')
			if lec_buf.cmd:find('%A+') then
				local characters_to_remove = {
					'Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ', 'Ф', 'Ы', 'В', 'А',
					'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э', 'Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю',
					'Ё', 'й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ', 'ф', 'ы', 'в',
					'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю'
				}
				local remove_pattern = '[' .. table.concat(characters_to_remove, '') .. ']'
				lec_buf.cmd = string.gsub(lec_buf.cmd, remove_pattern, '')
			end
			imgui.SetCursorPos(imgui.ImVec2(35, 34))
			imgui.Text(u8'Команда   /')
			
			
			new_draw(79, 44)
			imgui.SetCursorPos(imgui.ImVec2(35, 91))
			imgui.Text(u8'Задержка проигрывания отыгровки')
			skin.Slider('##Задержка проигрывания отыгровки лекции', 'lec_buf.wait', 400, 10000, 205, {470, 90}, nil)
			imgui.SetCursorPos(imgui.ImVec2(417, 89))
			imgui.Text(round(lec_buf.wait / 1000, 0.1)..u8' сек.')
			
			new_draw(135, 53 + (#lec_buf.q * 40))
			if #lec_buf.q ~= 0 then
				local remove_table_qq
				for i = 1, #lec_buf.q do
					skin.InputText(30, 149 + ((i - 1) * 40), u8'Введите отыгровку##'..i, 'lec_buf.q.'..i, 1024, 595)
					
					imgui.SetCursorPos(imgui.ImVec2(647, 148 + ((i - 1) * 40)))
					if imgui.InvisibleButton(u8'##Удалить отыгровку'..i, imgui.ImVec2(22, 22)) then remove_table_qq = i end
					imgui.PushFont(fa_font[1])
					imgui.SetCursorPos(imgui.ImVec2(651, 153 + ((i - 1) * 40)))
					imgui.Text(fa.ICON_TRASH)
					imgui.PopFont()
				end
				if remove_table_qq ~= nil then table.remove(lec_buf.q, remove_table_qq) end
			end
			skin.Button(u8'Добавить отыгровку', 242, 149 + (#lec_buf.q * 40), 173, 25, function() table.insert(lec_buf.q, '') end)
			imgui.PopFont()
			
			imgui.Dummy(imgui.ImVec2(0, 29))
			imgui.EndChild()
		end
		
	----> [10] О скрипте
	elseif select_main_menu[10] then
		local function new_draw(pos_draw, par_dr_y)
			imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
			end
		end
		
		menu_draw_up(u8'О скрипте')
		imgui.SetCursorPos(imgui.ImVec2(180, 41))
		imgui.BeginChild(u8'О скрипте', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
		
		new_draw(17, 40)
		imgui.PushFont(bold_font[3])
		local calc = imgui.CalcTextSize('State Helper Premium '..scr.version)
		imgui.SetCursorPos(imgui.ImVec2(332 - (calc.x / 2), 25))
		imgui.Text('State Helper Premium '..scr.version)
		imgui.PopFont()
		
		new_draw(69, 43)
		imgui.PushFont(font[1])
		imgui.SetCursorPos(imgui.ImVec2(15, 81))
		imgui.Text(u8'© 2023 ИТД Марсель Афанасьев. Все права защищены. Копирование запрещено.')
		new_draw(124, 43)
		imgui.SetCursorPos(imgui.ImVec2(15, 136))
		imgui.Text(u8'Поддержать разработчика: 5469 9804 2297 5769 (номер карты)')
		new_draw(179, 54)
		skin.Button(u8'Задать вопрос разработчику', 15, 191, 636, 30, function()
			shell32.ShellExecuteA(nil, 'open', 'https://vk.me/marseloy', nil, nil, 1)
		end)
		new_draw(245, 54)
		skin.Button(u8'Открыть пользовательское соглашение', 15, 257, 636, 30, function()
			shell32.ShellExecuteA(nil, 'open', 'https://raw.githubusercontent.com/KaneScripter/StateHelper/main/Пользовательское%20соглашение.txt', nil, nil, 1)
		end)
		imgui.PopFont()
		imgui.EndChild()
	end
	
	imgui.End()
end

function window.music()
	imgui.SetNextWindowSize(imgui.ImVec2(328, 98), imgui.Cond.Always)
	imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy - 60), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
	imgui.Begin('Musec Window', win.music.v, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
	skin.DrawFond({4, 4}, {0, 0}, {320, 90}, imgui.ImVec4(0.00, 0.00, 0.00, 1.00), 15, 15) --0.17, 0.17, 0.17, 1.00
	
	imgui.SetCursorPos(imgui.ImVec2(15, 14))
	if selectis == status_image then
		imgui.Image(IMG_label, imgui.ImVec2(70, 70))
	elseif select_record == 0 then
		imgui.Image(IMG_No_Label, imgui.ImVec2(70, 70))
	else
		imgui.Image(IMG_Record[select_record], imgui.ImVec2(70, 70))
	end
	
	imgui.SetCursorPos(imgui.ImVec2(15, 14))
	imgui.Image(IMG_Background_Black, imgui.ImVec2(70, 70))
	
	if status_track_pl == 'PAUSE' then
		imgui.SetCursorPos(imgui.ImVec2(15, 14))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 70, p.y + 70), imgui.GetColorU32(imgui.ImVec4(0.00, 0.00, 0.00, 0.60)))
		
		imgui.PushFont(fa_font[5])
		imgui.SetCursorPos(imgui.ImVec2(39, 36))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), fa.ICON_PAUSE)
		imgui.PopFont()
	end
	
	imgui.SetCursorPos(imgui.ImVec2(96, 75))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 217, p.y + 3), imgui.GetColorU32(imgui.ImVec4(0.50, 0.50, 0.50, 0.40)))
	
	if not menu_play_track[3] then
		local size_X_line = ((timetr[2] * 60 + timetr[1]) * timetri) * 0.5425
		if size_X_line > 217 then
			size_X_line = 217
		end
		imgui.SetCursorPos(imgui.ImVec2(96, 75))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + size_X_line, p.y + 3), imgui.GetColorU32(imgui.ImVec4(0.80, 0.80, 0.80, 1.00)))
	else
		imgui.SetCursorPos(imgui.ImVec2(96, 75))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 217, p.y + 3), imgui.GetColorU32(imgui.ImVec4(0.80, 0.80, 0.80, 1.00)))
	end
	
	imgui.PushFont(font[7])
	local artist_buf = imgui.ImBuffer(22)
	local name_buf = imgui.ImBuffer(22)
	local artist_end = artist
	local name_end = name_tr
	artist_buf.v = artist
	name_buf.v = name_tr
	if artist_buf.v ~= artist then artist_end = artist_buf.v..'...' end
	if name_buf.v ~= name_tr then name_end = name_buf.v..'...' end
	imgui.SetCursorPos(imgui.ImVec2(96, 20))
	imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), u8(artist_end))
	imgui.SetCursorPos(imgui.ImVec2(96, 42))
	imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.70), u8(name_end))
	
	imgui.PopFont()
	imgui.End()
end

function window.act_choice()
	if sampIsPlayerConnected(targ_id) then
		imgui.SetNextWindowSize(imgui.ImVec2(278, 165 + ((#setting.fast_acc.sl - 1) * 35)), imgui.Cond.Always)
		imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
		imgui.Begin('Choice Window', win.action_choice.v, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
		skin.DrawFond({4, 4}, {0, 0}, {270, 161 + ((#setting.fast_acc.sl - 1) * 35)}, imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00), 15, 15)
		
		imgui.PushFont(font[4])
		local calc = imgui.CalcTextSize(flies_nick..' ['..flies_id..']')
		imgui.SetCursorPos(imgui.ImVec2(130 - calc.x / 2, 4))
		local p = imgui.GetCursorScreenPos()
		if setting.int.theme == 'White' then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + calc.x + 18, p.y + 35), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10, 1.00)), 13, 12)
			imgui.SetCursorPos(imgui.ImVec2(139 - calc.x / 2, 9))
			imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), flies_nick..' ['..flies_id..']')
		else
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + calc.x + 18, p.y + 35), imgui.GetColorU32(imgui.ImVec4(0.90, 0.90, 0.90, 1.00)), 13, 12)
			imgui.SetCursorPos(imgui.ImVec2(139 - calc.x / 2, 9))
			imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00, 1.00), flies_nick..' ['..flies_id..']')
		end
		imgui.PopFont()
		
		imgui.PushFont(font[1])
		for i = 1, #setting.fast_acc.sl do
			local bool_cmd = true
			for k = 1, #setting.cmd do
				if setting.cmd[k][1] == setting.fast_acc.sl[i].cmd then
					if tonumber(setting.frac.rank) < tonumber(setting.cmd[k][4]) then
						bool_cmd = false
					end
					break
				end
			end
			
			if bool_cmd then
				skin.Button(setting.fast_acc.sl[i].text..'##ch_text'..i, 9, 60 + ((i - 1) * 35), 260, 30, function()
					if sampIsPlayerConnected(flies_id) then
						local cmd_send_chat = '/'..setting.fast_acc.sl[i].cmd
						local arg_tr = ''
						if setting.fast_acc.sl[i].pass_arg then
							cmd_send_chat = cmd_send_chat..' '..flies_id
							arg_tr = flies_id
						end
						if setting.fast_acc.sl[i].send_chat then
							local tr_cmd = false
							for c = 1, #setting.cmd do
								if setting.cmd[c][1] == setting.fast_acc.sl[i].cmd then tr_cmd = true break end
							end
							if tr_cmd then
								cmd_start(tostring(arg_tr), setting.fast_acc.sl[i].cmd)
							else
								sampSendChat(cmd_send_chat)
							end
						else
							sampSetChatInputEnabled(true)
							sampSetChatInputText(cmd_send_chat)
						end
						win.action_choice.v = false
					end
				end)
			else
				skin.Button(setting.fast_acc.sl[i].text..'##ch_text'..i..'##false_non', 9, 60 + ((i - 1) * 35), 260, 30, function() end)
				imgui.PushFont(fa_font[1])
				imgui.SetCursorPos(imgui.ImVec2(250, 70 + ((i - 1) * 35)))
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), fa.ICON_LOCK)
				imgui.PopFont()
			end
		end
		
		skin.Button(u8'Отменить', 9, 80 + (#setting.fast_acc.sl * 35), 260, 35, function()
			win.action_choice.v = false
		end)
		imgui.PopFont()
		
		imgui.End()
	end
end

function window.spur()
	imgui.SetNextWindowSize(imgui.ImVec2(908, 658), imgui.Cond.FirstUseEver)
	imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.Begin('Spur Window', win.action_choice.v, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
	skin.DrawFond({4, 4}, {0, 0}, {900, 650}, imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00), 15, 15)
	
	imgui.SetCursorPos(imgui.ImVec2(13, 13))
	if imgui.InvisibleButton(u8'##Закрыть окно шпоры', imgui.ImVec2(20, 20))  then
		win.spur_big.v = false
	end
	imgui.SetCursorPos(imgui.ImVec2(23, 23))
	local p = imgui.GetCursorScreenPos()
	if imgui.IsItemHovered() then
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
		imgui.SetCursorPos(imgui.ImVec2(19, 16))
		imgui.PushFont(fa_font[2])
		imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
		imgui.PopFont()
	else
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
	end
	
	local options_size_font = {6, 3, 1, 4, 5}
	imgui.PushFont(font[1])
	imgui.SetCursorPos(imgui.ImVec2(40, 10))
	if skin.Slider('##Размер текста', 'spur_text_size', 0, 4, 130, {50, 11}) then end
	imgui.PopFont()
	
	local text_spur_table = {}
	for line in text_spur:gmatch('[^\n]*\n?') do
		table.insert(text_spur_table, line:match('^(.-)\n?$'))
	end
	
	imgui.SetCursorPos(imgui.ImVec2(15, 50))
	imgui.BeginChild(u8'Текст шпаргалки', imgui.ImVec2(879, 603), false)
	imgui.PushFont(font[options_size_font[round(spur_text_size, 1) + 1]])
	for i, line in ipairs(text_spur_table) do
		imgui.TextWrapped(line)
	end
	imgui.PopFont()
	imgui.EndChild()
	
	imgui.End()
end

function window.reminder()
	imgui.SetNextWindowSize(imgui.ImVec2(608, 122), imgui.Cond.FirstUseEver)
	imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.Begin('Spur Window', win.action_choice.v, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
	skin.DrawFond({4, 4}, {0, 0}, {600, 114}, imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00), 15, 15)
	
	imgui.SetCursorPos(imgui.ImVec2(13, 13))
	if imgui.InvisibleButton(u8'##Закрыть окно напоминания', imgui.ImVec2(20, 20))  then
		win.reminder.v = false
	end
	imgui.SetCursorPos(imgui.ImVec2(23, 23))
	local p = imgui.GetCursorScreenPos()
	if imgui.IsItemHovered() then
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
		imgui.SetCursorPos(imgui.ImVec2(19, 16))
		imgui.PushFont(fa_font[2])
		imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
		imgui.PopFont()
	else
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
	end
	
	imgui.PushFont(font[4])
	local calc = imgui.CalcTextSize(rem_text)
	imgui.SetCursorPos(imgui.ImVec2(304 - (calc.x / 2), 50))
	imgui.Text(rem_text)
	imgui.PopFont()
	imgui.End()
end

function window.icon()
	imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(240, 700))
	imgui.Begin('Window Icon', false, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
	
	for i,v in pairs(fa) do
		imgui.PushFont(fa_font[1])
		if imgui.Button(fa[i]..' - '..i, imgui.ImVec2(210, 25)) then setClipboardText(i) end
		imgui.PopFont()
	end
	
	imgui.End()
end

function open_big_shpora(spur_number)
	if spur_number > #setting.shpora then
		sampAddChatMessage(script_tag..'{FFFFFF} Такой шпаргалки не существует. Всего их '..#setting.shpora, color_tag)
		return
	elseif spur_number <= 0 then
		sampAddChatMessage(script_tag..'{FFFFFF} Отсчёт шпаргалок начинается с единицы!', color_tag)
		return
	end
	
	if doesFileExist(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[spur_number][1]..'.txt') then
		sel_big_spur = spur_number
		local f = io.open(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[spur_number][1]..'.txt')
		text_spur = u8(f:read('*a'))
		f:close()			
		win.spur_big.v = true
	end
end

local notif_manag = {
	s_y = 100,
	p_x = -150
}
function window.notice()
	if notif_manag.p_x < 160 and wind_act_wait then 
		notif_manag.p_x = notif_manag.p_x + 15
	elseif not wind_act_wait and notif_manag.p_x > -150 then
		notif_manag.p_x = notif_manag.p_x - 15
	elseif not wind_act_wait and notif_manag.p_x <= -150 then
		win.notice.v = false
	end
	
	imgui.SetNextWindowPos(imgui.ImVec2(sx - notif_manag.p_x, sy - (notif_manag.s_y / 2 + 10)), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(308, notif_manag.s_y + 8))
	imgui.Begin('Window Wait Notice', false, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
	skin.DrawFond({4, 4}, {0, 0}, {300, notif_manag.s_y}, imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 0.80), 15, 15)
	
	imgui.PushFont(font[4])
	if all_text_notice ~= nil then
		for i = 1, #all_text_notice do
			imgui.SetCursorPos(imgui.ImVec2(20, 23 + ((i - 1) * 27)))
			imgui.Text(all_text_notice[i])
		end
	end
	imgui.PopFont()
	
	imgui.End()
end
win.notice.v = false
wind_act_wait = false
all_text_notice = {}

function new_notice(type_notice, text_notice)
	if type_notice == 'wait' then
		all_text_notice = text_notice
		notif_manag.s_y = 36 + (#all_text_notice * 27)
		wind_act_wait = true
		win.notice.v = true
	elseif type_notice == 'off' then
		wind_act_wait = false
	else
		all_text_notice = text_notice
		lua_thread.create(function()
			wind_act_wait = true
			win.notice.v = true
			wait(6000)
			wind_act_wait = false
		end)
	end
	showCursor(false)
end

color_w = {
	fond_one = {0.91, 0.89, 0.76, 1.00},
	fond_two = {0.96, 0.94, 0.93, 1.00},
	text = 0.00
}

color_b = {
	fond_one = {0.14, 0.14, 0.15, 1.00},
	fond_two = {0.12, 0.12, 0.12, 1.00},
	text = 1.00
}

col_end = {
	fond_one = {0.91, 0.89, 0.76, 1.00},
	fond_two = {0.96, 0.94, 0.93, 1.00},
	text = 0.00
}

if setting.int.theme == 'Black' then
	col_end = {
		fond_one = {0.14, 0.14, 0.15, 1.00},
		fond_two = {0.12, 0.12, 0.12, 1.00},
		text = 1.00
	}
end

function color_accent()
	
end

function style_window()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	style.WindowRounding = 15.0
	style.ChildWindowRounding = 10.0
	style.FrameRounding = 8.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ScrollbarSize = 15.0
	style.FramePadding = imgui.ImVec2(5, 3)
	style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
	style.ScrollbarRounding = 0
	style.GrabMinSize = 18.0
	style.GrabRounding = 4.0
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
	
	colors[clr.FrameBg] 			 = ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00) -- Чекбокс
	colors[clr.FrameBgHovered]       = ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00) -- Чекбокс
	colors[clr.FrameBgActive]        = ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00) -- Чекбокс
	colors[clr.TitleBg]              = ImVec4(0.00, 0.00, 0.00, 0.50)
	colors[clr.TitleBgActive]        = ImVec4(1.00, 1.00, 1.00, 0.31)
	colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.50)
	colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 0.31)
	colors[clr.SliderGrab]           = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.SliderGrabActive]     = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.Button]               = ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00) -- Кнопка
	colors[clr.ButtonHovered]        = ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00) -- Кнопка
	colors[clr.ButtonActive]         = ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00) -- Кнопка
	colors[clr.Header]               = ImVec4(1.00, 1.00, 1.00, 0.65)
	colors[clr.HeaderHovered]        = ImVec4(1.00, 1.00, 1.00, 0.80)
	colors[clr.HeaderActive]         = ImVec4(1.00, 1.00, 1.00, 0.90)
	colors[clr.Separator]            = ImVec4(0.37, 0.37, 0.37, 0.60)
	colors[clr.SeparatorHovered]     = ImVec4(0.37, 0.37, 0.37, 0.60)
	colors[clr.SeparatorActive]      = ImVec4(0.37, 0.37, 0.37, 0.60)
	colors[clr.ResizeGrip]           = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.ResizeGripHovered]    = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.ResizeGripActive]     = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.TextSelectedBg]       = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.Text]                 = ImVec4(col_end.text, col_end.text, col_end.text, 1.00) -- Текст
	colors[clr.TextDisabled]         = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]             = ImVec4(0.08, 0.08, 0.08, 0.00)
	colors[clr.ChildWindowBg]        = ImVec4(1.00, 1.00, 1.00, 0.00)
	if setting.int.theme == 'White' then
		colors[clr.PopupBg]          = ImVec4(0.80, 0.80, 0.80, 1.00) -- Окно
	else
		colors[clr.PopupBg]          = ImVec4(0.10, 0.10, 0.10, 1.00) -- Окно
	end
	colors[clr.ComboBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border]               = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.BorderShadow]         = ImVec4(0.26, 0.59, 0.98, 0.00)
	colors[clr.MenuBarBg]            = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]          = ImVec4(0.00, 0.00, 0.00, 0.00) -- Пролистывающая дрянь
	colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00) -- Пролистывающая дрянь
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00) -- Пролистывающая дрянь
	colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00) -- Пролистывающая дрянь
	colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end

--> Сохранение
function save(table_name)
	if table_name == 'setting' then
		local f = io.open(dirml..'/StateHelper/Настройки.json', 'w')
		f:write(encodeJson(setting))
		f:flush()
		f:close()
	elseif table_name == 'save_tracks' then
		local f = io.open(dirml..'/StateHelper/Треки.json', 'w')
		f:write(encodeJson(save_tracks))
		f:flush()
		f:close()
	elseif table_name == 'scene' then
		local f = io.open(dirml..'/StateHelper/Сцены.json', 'w')
		f:write(encodeJson(scene))
		f:flush()
		f:close()
	end
end

--[[
	0 - Отправить в чат
	1 - Ожидание нажатия Enter
	2 - Вывести инфо в чат
	3 - Диалог выбора действия
	4 - Комментарий
	5 - Изменить переменную
	6 - Если переменная равна
	7 - Завершить условие переменной
	8 - Если выбран вариант диалога
	9 - Завершить диалог
]]
			
function cmd_start(arg_c, command_active)
	if thread:status() ~= 'dead' then
		sampAddChatMessage(script_tag..'{FFFFFF}У Вас уже запущена отыгровка! Используйте {ED95A8}Page Down{FFFFFF}, чтобы остановить её.', color_tag)
		return
	end
	
	local f = io.open(dirml..'/StateHelper/Отыгровки/'..command_active..'.json')
	local setm = f:read('*a')
	f:close()
	local res, set = pcall(decodeJson, setm)
	if res and type(set) == 'table' then 
		cmds = set
	end
	
	if tonumber(setting.frac.rank) < tonumber(cmds.rank) then
		sampAddChatMessage(script_tag..'{FFFFFF}Данная команда доступна с '..cmds.rank..' ранга!', color_tag)
		return
	end
	
	local args = {}
	if cmds.arg ~= 0 then
		local function invalid_arguments()
			local tbl_ar = {}
			for ar = 1, #cmds.arg do
				table.insert(tbl_ar, '['..u8:decode(cmds.arg[ar][2])..']')
			end
			sampAddChatMessage(script_tag..'{FFFFFF}Используйте {a8a8a8}/'..command_active..' '..table.concat(tbl_ar, ' '), color_tag)
		end
		for word in arg_c:gmatch('%S+') do
		   table.insert(args, word)
		end
		for arg_i, arg_v in ipairs(cmds.arg) do
			if arg_v[1] == 0 then
				if args[arg_i] ~= nil then
					if not args[arg_i]:find('^(%d+)$') then invalid_arguments() return end
				else
					invalid_arguments() return
				end
			elseif arg_v[1] == 1 then
				if args[arg_i] ~= nil then
					if not args[arg_i]:find('(.+)') then invalid_arguments() return end
				else
					invalid_arguments() return
				end
			end
		end
	end
	
	local not_send_chat
	if cmds.not_send_chat then
		for mess = 1, #cmds do
			if cmds.act[mess][1] == 0 then
				not_send_chat = mess
			end
		end
	end
	
	local function conv_tag(text_to_convert)
		local stop_send_chat = false
		local num_id_dial = -1
		local num_id_player = 0
		local mass_tags = {}
		for value in text_to_convert:gmatch('{(.-)}') do
		  table.insert(mass_tags, '{' .. value .. '}')
		end
		if #mass_tags == 0 then return text_to_convert end
		for value in text_to_convert:gmatch('{arg(%d+)}') do
			if text_to_convert:find('{arg(%d+)}') then
				local number = tonumber(text_to_convert:match('{arg(%d+)}'))
				if text_to_convert:find('{arg'..number..'}') and cmds.arg[number] ~= nil then
					text_to_convert = text_to_convert:gsub('{arg'..number..'}', u8(args[number]))
				end
			end
		end
		for value in text_to_convert:gmatch('{var(%d+)}') do
			if text_to_convert:find('{var(%d+)}') then
				local number = tonumber(text_to_convert:match('{var(%d+)}'))
				if text_to_convert:find('{var'..number..'}') and cmds.var[number] ~= nil then
					text_to_convert = text_to_convert:gsub('{var'..number..'}', cmds.var[number][2])
				end
			end
		end
		if text_to_convert:find('{prtsc}') then
			stop_send_chat = true
			text_to_convert = text_to_convert:gsub('{prtsc}', '')
			print_scr()
		end
		
		text_to_convert = tag_act(text_to_convert)
		
		if text_to_convert:find('{dialoglic%[(%d+)%]%[(%d+)%]%[(%d+)%]}') then
			stop_send_chat = true
			num_id_dial, num_id_term, num_id_player = string.match(text_to_convert, '{dialoglic%[(.-)%]%[(.-)%]%[(.-)%]}')
			if tonumber(num_id_dial) > -1 and tonumber(num_id_dial) < 10 then
				num_give_lic = tonumber(num_id_dial)
			else
				sampAddChatMessage(script_tag..'{FF5345}[КРИТИЧЕСКАЯ ОШИБКА] {FFFFFF}Параметр {dialoglic} имеет неверное значение.', color_tag)
				return ''
			end
			if tonumber(num_id_term) >= 0 and tonumber(num_id_term) <= 3 then
				num_give_lic_term = tonumber(num_id_term)
			else
				sampAddChatMessage(script_tag..'{FF5345}[КРИТИЧЕСКАЯ ОШИБКА] {FFFFFF}Параметр {dialoglic} имеет неверное значение.', color_tag)
				return ''
			end
		end
		if stop_send_chat then return '/givelicense '..num_id_player end
		
		if text_to_convert:find('{dialogbank%[(%d+)%]%[(%d+)%]}') then
			stop_send_chat = true
			num_id_dial, num_id_player = string.match(text_to_convert, '{dialogbank%[(.-)%]%[(.-)%]}')
			if tonumber(num_id_dial) > -1 and tonumber(num_id_dial) < 12 then
				num_give_bank = tonumber(num_id_dial)
			else
				sampAddChatMessage(script_tag..'{FF5345}[КРИТИЧЕСКАЯ ОШИБКА] {FFFFFF}Параметр {dialogbank} имеет неверное значение.', color_tag)
				return ''
			end
		end
		if stop_send_chat then return '/bankmenu '..num_id_player end
		
		return text_to_convert
	end
	
	local function are_all_false(arr)
		for i = 1, #arr do
			if arr[i] ~= false then
				return false
			end
		end
		return true
	end
	
	local delay = cmds.delay
	local dialogs = {}
	local bool = {}
	
	thread = lua_thread.create(function()
		for i, v in ipairs(cmds.act) do
			if are_all_false(bool) then
				if v[1] == 0 then
					local message_end = ((u8:decode(conv_tag(v[2]))))
					if i ~= 1 then
						if cmds.act[i - 1][1] == 0 then
							wait(delay)
						end
					end
					if not cmds.not_send_chat then
						sampSendChat(message_end)
					elseif cmds.not_send_chat and i ~= not_send_chat then
						sampSendChat(message_end)
					elseif cmds.not_send_chat and i == not_send_chat then
						sampSetChatInputEnabled(true)
						sampSetChatInputText(message_end)
					end
				elseif v[1] == 1 then
					wait(400)
					sampAddChatMessage(script_tag..'{FFFFFF}Нажмите на {23E64A}Enter{FFFFFF} для продолжения или {FF8FA2}Page Down{FFFFFF}, чтобы закончить отыгровку.', color_tag)
					addOneOffSound(0, 0, 0, 1058)
					new_notice('wait', {u8'Enter - продолжить отыгровку', u8'Page Down - остановить'})
					while true do wait(0)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then new_notice('off') break end
					end
				elseif v[1] == 2 then
					local message_end = ((u8:decode(conv_tag(v[2]))))
					sampAddChatMessage(script_tag..'{FFFFFF}'..message_end, color_tag)
				elseif v[1] == 3 then
					local dr_texts = {}
					for t = 1, v[3] do
						table.insert(dr_texts, u8'Num '..t..' - '..v[4][t])
					end
					new_notice('wait', dr_texts)
					while true do wait(0)
						if not sampIsChatInputActive() and not sampIsDialogActive() then
							if isKeyJustPressed(VK_1) or isKeyJustPressed(VK_NUMPAD1) then table.insert(dialogs, {v[2], 1, false}) new_notice('off') break end
							if isKeyJustPressed(VK_2) or isKeyJustPressed(VK_NUMPAD2) then table.insert(dialogs, {v[2], 2, false}) new_notice('off') break end
							if isKeyJustPressed(VK_3) or isKeyJustPressed(VK_NUMPAD3) then table.insert(dialogs, {v[2], 3, false}) new_notice('off') break end
							if isKeyJustPressed(VK_4) or isKeyJustPressed(VK_NUMPAD4) then table.insert(dialogs, {v[2], 4, false}) new_notice('off') break end
							if isKeyJustPressed(VK_5) or isKeyJustPressed(VK_NUMPAD5) then table.insert(dialogs, {v[2], 5, false}) new_notice('off') break end
						end
					end
				elseif v[1] == 5 then
					local number = tonumber(string.match(v[2], '%d+'))
					if cmds.var[number] ~= nil then cmds.var[number][2] = v[3] end
				elseif v[1] == 6 then
					table.insert(bool, true)
					local number = tonumber(string.match(v[2], '%d+'))
					for vr = 1, #cmds.var do
						if cmds.var[vr][1] == number and u8:decode(cmds.var[vr][2]) == u8:decode(v[3]) then
						bool[#bool] = false end break
					end
				elseif v[1] == 7 then
					local number = tonumber(string.match(v[2], '%d+'))
					table.remove(bool, #bool)
				elseif v[1] == 8 then
					table.insert(bool, true)
					for m = 1, #dialogs do
						if dialogs[m][1] == tonumber(v[2]) then
							if dialogs[m][2] == tonumber(v[3]) then
								bool[#bool] = false
								break
							end
						end
					end
				elseif v[1] == 9 then
					table.remove(bool, #bool)
				end
			else
				if v[1] == 7 or v[1] == 9 then
					table.remove(bool, #bool)
				elseif v[1] == 8 or v[1] == 6 then
					table.insert(bool, true)
				end
			end
		end
		new_notice('off')
	end)
end

function tag_act(tick_tag)
	tick_tag = u8:decode(tick_tag)
	if tick_tag:find('%b{}') then
		local tabl_check = {}
		for match in tick_tag:gmatch('%b{}') do
		   table.insert(tabl_check, match:sub(2, -2))
		end
		
		for t = 1, #tabl_check do
			if tick_tag:find('{mynick}') then tick_tag = tick_tag:gsub('{mynick}', tostring(sampGetPlayerNickname(my.id):gsub('_', ' ')))
			elseif tick_tag:find('{mynickrus}') then tick_tag = tick_tag:gsub('{mynickrus}', tostring(u8:decode(setting.nick)))
			elseif tick_tag:find('{myrank}') then tick_tag = tick_tag:gsub('{myrank}', tostring(u8:decode(setting.frac.title)))
			elseif tick_tag:find('{myid}') then tick_tag = tick_tag:gsub('{myid}', tostring(my.id))
			elseif tick_tag:find('{time}') then tick_tag = tick_tag:gsub('{time}', tostring(os.date('%X')))
			elseif tick_tag:find('{day}') then tick_tag = tick_tag:gsub('{day}', tostring(tonumber(os.date('%d'))))
			elseif tick_tag:find('{week}') then tick_tag = tick_tag:gsub('{week}', tostring(week[tonumber(os.date('%w'))]))
			elseif tick_tag:find('{month}') then tick_tag = tick_tag:gsub('{month}', tostring(month[tonumber(os.date('%m'))]))
			elseif tick_tag:find('{getplnick(%[(%d+)%])}') then
				local num_id = string.match(tick_tag, '{getplnick%[(.-)%]}')
				if sampIsPlayerConnected(tonumber(num_id)) then
					tick_tag = tick_tag:gsub('{getplnick%['.. num_id ..'%]}', tostring(sampGetPlayerNickname(tonumber(num_id))):gsub('_', ' '))
				else
					tick_tag = tick_tag:gsub('{getplnick%['.. num_id ..'%]}', u8'неизвестный')
					sampAddChatMessage(script_tag..'{FF5345}[КРИТИЧЕСКАЯ ОШИБКА] {FFFFFF}Параметр {getplnick} не обнаружил игрока.', color_tag)
				end
			elseif tick_tag:find('{target}') then tick_tag = tick_tag:gsub('{target}', tostring(targ_id))
			elseif tick_tag:find('{med7}') then tick_tag = tick_tag:gsub('{med7}', tostring(setting.price.mede[1]))
			elseif tick_tag:find('{med14}') then tick_tag = tick_tag:gsub('{med14}', tostring(setting.price.mede[2]))
			elseif tick_tag:find('{med30}') then tick_tag = tick_tag:gsub('{med30}', tostring(setting.price.mede[3]))
			elseif tick_tag:find('{med60}') then tick_tag = tick_tag:gsub('{med60}', tostring(setting.price.mede[4]))
			elseif tick_tag:find('{medup7}') then tick_tag = tick_tag:gsub('{medup7}', tostring(setting.price.upmede[1]))
			elseif tick_tag:find('{medup14}') then tick_tag = tick_tag:gsub('{medup14}', tostring(setting.price.upmede[2]))
			elseif tick_tag:find('{medup30}') then tick_tag = tick_tag:gsub('{medup30}', tostring(setting.price.upmede[3]))
			elseif tick_tag:find('{medup60}') then tick_tag = tick_tag:gsub('{medup60}', tostring(setting.price.upmede[4]))
			elseif tick_tag:find('{pricenarko}') then tick_tag = tick_tag:gsub('{pricenarko}', tostring(setting.price.narko))
			elseif tick_tag:find('{pricerecept}') then tick_tag = tick_tag:gsub('{pricerecept}', tostring(setting.price.rec))
			elseif tick_tag:find('{pricetatu}') then tick_tag = tick_tag:gsub('{pricetatu}', tostring(setting.price.tatu))
			elseif tick_tag:find('{priceant}') then tick_tag = tick_tag:gsub('{priceant}', tostring(setting.price.ant))
			elseif tick_tag:find('{pricelec}') then tick_tag = tick_tag:gsub('{pricelec}', tostring(setting.price.lec))
			elseif tick_tag:find('{priceosm}') then tick_tag = tick_tag:gsub('{priceosm}', tostring(setting.priceosm))
			elseif tick_tag:find('{sex:[%w%sа-яА-Я]*,[%w%sа-яА-Я]*}') then	
				for v in tick_tag:gmatch('{sex:[%w%sа-яА-Я]*,[%w%sа-яА-Я]*}') do
					local m, w = v:match('{sex:([%w%sа-яА-Я]*),([%w%sа-яА-Я]*)}')
					if setting.sex == u8'Мужской' then
						tick_tag = tick_tag:gsub(v, m)
					else
						tick_tag = tick_tag:gsub(v, w)
					end
				end
			end
		end
	end
	
	return u8(tick_tag)
end

function lec_start(text_arg, cmd_lec)
	if thread:status() ~= 'dead' then
		sampAddChatMessage(script_tag..'{FFFFFF}У Вас уже запущена отыгровка! Используйте {ED95A8}Page Down{FFFFFF}, чтобы остановить её.', color_tag)
		return
	end
	
	local select_lec_i
	for i = 1, #setting.lec do
		if setting.lec[i].cmd == cmd_lec then select_lec_i = setting.lec[i] end
	end
	
	if select_lec_i ~= nil then
		thread = lua_thread.create(function()
			for i, v in ipairs(select_lec_i.q) do
				if v ~= nil then
					local message_end = ((u8:decode(tag_act(v))))
					if i ~= 1 then
						wait(select_lec_i.wait)
						sampSendChat(message_end)
					else
						sampSendChat(message_end)
					end
				end
			end
		end)		
	end
end

function add_table_act(org_to_replace, default_act)
	local add_table
	local function create_file_json(name_file_json, desc_act, table_to_save, rank)
		local bool_true = false
		if desc_act ~= nil then
			if #setting.cmd ~= 0 then
				for i = 1, #setting.cmd do
					if setting.cmd[i][1] == name_file_json then
						bool_true = true
						break
					end
				end
			end
		end
		if not bool_true then
			local f = io.open(dirml..'/StateHelper/Отыгровки/'..name_file_json..'.json', 'w')
			f:write(encodeJson(table_to_save))
			f:flush()
			f:close()
			
			sampRegisterChatCommand(name_file_json, function(arg) cmd_start(arg, name_file_json) end)
			
			if desc_act ~= nil then
				table.insert(setting.cmd, {name_file_json, desc_act, {}, rank})
				save('setting')
			end
		end
	end
	if default_act then
		add_table = {
			arg = {},
			nm = 'z',
			var = {},
			tr_fl = {0, 0, 0},
			desc = u8'Приветствие',
			act = {
				{0, u8'Здравствуйте, меня зовут {mynickrus}, чем могу быть полезен?'}
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '1'
		}
		create_file_json('z', nil, add_table, '1')
		add_table = {
			arg = {
				{0, u8'id игрока'},
				{1, u8'Причина'}
			},
			nm = 'exp',
			var = {},
			tr_fl = {0, 0, 0},
			desc = u8'Выгнать из помещения',
			act = {
				{0, u8'/me резким движением руки ухватил{sex:ся,ась} за воротник нарушителя'},
				{0, u8'/do Крепко держит нарушителя за воротник.'},
				{0, u8'/todo Я вынужден{sex:,а} вывести вас из здания*направляясь к выходу'},
				{0, u8'/me движением левой руки открыл{sex:,а} входную дверь, после чего вытолкнул{sex:,а} нарушителя'},
				{0, u8'/expel {arg1} {arg2}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '3'
		}
		create_file_json('exp', nil, add_table, '3')
		add_table = {
			arg = {},
			nm = 'za',
			var = {},
			act = {
				{0, u8'Пройдёмте за мной.'}
			},
			desc = u8'Отправит фразу "Пройдёмте за мной"',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '1'
		}
		create_file_json('za', nil, add_table, '1')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'show',
			var = {},
			act = {
				{3, 1, 3, {u8'Паспорт', u8'Медицинская карта', u8'Лицензии'}},
				{8, '1', '1'},
				{0, u8'/do Паспорт гражданина находится в заднем кармане.'},
				{0, u8'/me засунув руку в карман, достал{sex:,а} паспорт, после чего передал{sex:,а} его человеку напротив'},
				{0, u8'/showpass {arg1}'},
				{9, '1', '1'},
				{8, '1', '2'},
				{0, u8'/do Медицинская карта находится в нагрудном кармане.'},
				{0, u8'/me засунув руку в карман, достал{sex:,а} мед. карту, после чего передал{sex:,а} её человеку напротив'},
				{0, u8'/showmc {arg1}'},
				{9, '1', '1'},
				{8, '1', '3'},
				{0, u8'/do Пакет лицензий находится в нагрудном кармане.'},
				{0, u8'/me засунув руку в карман, достал{sex:,а} лицензии, после чего передал{sex:,а} их человеку напротив'},
				{0, u8'/showlic {arg1}'},
				{9, '1', '1'}
			},
			desc = 'Показать игроку свои документы',
			tr_fl = {0, 1, 3},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '1'
		}
		create_file_json('show', nil, add_table, '1')
		add_table = {
			arg = {},
			nm = 'cam',
			var = {},
			act = {
				{3, 1, 2, {u8'Включить камеру', u8'Отключить камеру'}},
				{8, '1', '1'},
				{0, u8'/do Телефон находится в левом кармане.'},
				{0, u8'/me засунув руку в карман, достал{sex:,а} оттуда телефон, после чего заш{sex:ел,ла} в приложение \'Камера\''},
				{0, u8'/me нажав на кнопку записи, приступил{sex:,а} к съёмке происходящего'},
				{0, u8'/do Камера смартфона начала записывать видео и звук.'},
				{9, '1', '1'},
				{8, '1', '2'},
				{0, u8'/do Телефон находится в руке и ведёт запись.'},
				{0, u8'/me нажал{sex:,а} на кнопку отключения записи, после чего убрал{sex:,а} телефон в задний карман'},
				{0, u8'/do Видеофиксация происходящего приостановлена.'},
				{9, '1', '1'}
			},
			desc = u8'Начать или прекратить видеофиксацию',
			tr_fl = {0, 1, 2},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '1'
		}
		create_file_json('cam', nil, add_table, '1')
		add_table = {
			arg = {},
			nm = 'mb',
			var = {},
			act = {
				{0, u8'/members'}
			},
			desc = u8'Сокращённая команда /members',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '1'
		}
		create_file_json('mb', nil, add_table, '1')
		add_table = {
			arg = {
				{0, u8'id сотрудника'},
				{0, u8'Время в минутах'},
				{1, u8'Причина'}
			},
			nm = '+mute',
			var = {},
			act = {
				{0, u8'/do Рация весит на поясе.'},
				{0, u8'/me снял{sex:,а} рацию с пояса, после чего {sex:зашел,зашла} в настройки локальных частот вещания'},
				{0, u8'/me заглушил{sex:,а} локальную частоту вещания сотруднику {getplnick[{arg1}]}'},
				{0, u8'/fmute {arg1} {arg2} {arg3}'},
				{0, u8'/r Сотруднику {getplnick[{arg1}]} была отключена рация. Причина: {arg3}'}
			},
			desc = u8'Выдать бан чата организации сотруднику',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '8'
		}
		create_file_json('+mute', nil, add_table, '8')
		add_table = {
			arg = {
				{0, u8'id сотрудника'}
			},
			nm = '-mute',
			var = {},
			act = {
				{0, u8'/do Рация весит на поясе.'},
				{0, u8'/me снял{sex:,а} рацию с пояса, после чего {sex:зашел,зашла} в настройки локальных частот вещания'},
				{0, u8'/me освободил{sex:,а} локальную частоту вещания сотруднику {getplnick[{arg1}]}'},
				{0, u8'/funmute {arg1}'},
				{0, u8'/r Сотруднику {getplnick[{arg1}]} снова включена рация!'}
			},
			desc = u8'Снять бан чата организации сотруднику',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '8'
		}
		create_file_json('-mute', nil, add_table, '8')
		add_table = {
			arg = {
				{0, u8'id сотрудника'},
				{1, u8'Причина'}
			},
			nm = '+warn',
			var = {},
			tr_fl = {0, 0, 0},
			desc = u8'Выдать сотруднику выговор',
			act = {
				{0, u8'/do В левом кармане лежит телефон.'},
				{0, u8'/me достал{sex:,а} телефон из кармана, после чего {sex:зашел,зашла} в базу данных организации'},
				{0, u8'/me изменил{sex:,а} информацию о сотруднике {getplnick[{arg1}]}'},
				{0, u8'/fwarn {arg1} {arg2}'},
				{0, u8'/r {getplnick[{arg1}]} получил строгий выговор! Причина: {arg2}'}
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '8'
		}
		create_file_json('+warn', nil, add_table, '8')
		add_table = {
			arg = {
				{0, u8'id сотрудника'}
			},
			nm = '-warn',
			var = {},
			act = {
				{0, u8'/do В левом кармане лежит телефон.'},
				{0, u8'/me достал{sex:,а} телефон из кармана, после чего {sex:зашел,зашла} в базу данных организации'},
				{0, u8'/me изменил{sex:,а} информацию о сотруднике {getplnick[{arg1}]}'},
				{0, u8'/unfwarn {arg1}'},
				{0, u8'/r Сотруднику {getplnick[{arg1}]} снят строгий выговор!'}
			},
			desc = u8'Снять выговор сотруднику',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '8'
		}
		create_file_json('-warn', nil, add_table, '8')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'inv',
			var = {},
			act = {
				{0, u8'/do В кармане находятся ключи от шкафчика.'},
				{0, u8'/me потянувшись во внутренний карман, достал{sex:,а} оттуда ключ'},
				{0, u8'/me передал{sex:,а} ключ от шкафчика с формой человеку напротив'},
				{0, u8'/invite {arg1}'},
				{0, u8'/r Приветствуем нового сотрудника нашей организации - {getplnick[{arg1}]}'}
			},
			desc = u8'Принять игрока в организацию',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '9'
		}
		create_file_json('inv', nil, add_table, '9')
		add_table = {
			arg = {
				{0, u8'id сотрудника'},
				{1, u8'Причина'}
			},
			nm = 'uninv',
			var = {},
			act = {
				{0, u8'/do В левом кармане лежит телефон.'},
				{0, u8'/me достал{sex:,а} телефон из кармана, после чего {sex:зашел,зашла} в базу данных организации'},
				{0, u8'/me изменил{sex:,а} информацию о сотруднике {getplnick[{arg1}]}'},
				{0, u8'/uninvite {arg1} {arg2}'},
				{0, u8'/r Сотрудник {getplnick[{arg1}]} был уволен из организации. Причина: {arg2}'}
			},
			desc = u8'Уволить сотрудника',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '9'
		}
		create_file_json('uninv', nil, add_table, '9')
		add_table = {
			arg = {
				{0, u8'id сотрудника'},
				{0, u8'Номер ранга'}
			},
			nm = 'rank',
			var = {},
			act = {
				{0, u8'/do В кармане халата находится футляр с ключами от шкафчиков с формой.'},
				{0, u8'/me потянувшись во внутренний карман халата, достал{sex:,а} оттуда футляр'},
				{0, u8'/me открыв футляр, достал{sex:,а} оттуда ключ от шкафчика с формой'},
				{0, u8'/me передал{sex:,а} ключ от шкафчика человеку напротив'},
				{0, u8'/giverank {arg1} {arg2}'},
				{0, u8'/r Сотрудник {getplnick[{arg1}]} получил новую должность. Поздравляем!'}
			},
			desc = u8'Установить сотруднику ранг',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '9'
		}
		create_file_json('rank', nil, add_table, '9') 
	end
	
	if org_to_replace:find(u8'Больница') then
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'hl',
			var = {},
			act = {
				{0, u8'/do Медицинская сумка весит на левом плече.'},
				{0, u8'/me открыв сумку, достал{sex:,а} необходимое лекарство и передал{sex:,а} человеку напротив'},
				{0, u8'/heal {arg1} {pricelec}'}
			},
			desc = u8'Вылечить игрока',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '2'
		}
		create_file_json('hl', u8'Вылечить игрока', add_table, '2')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'mc',
			var = {{1, '0'}, {1, '0'}, {1, '0'}},
			tr_fl = {0, 4, 14},
			desc = u8'Оформить медицинскую карту',
			act = {
				{0, u8'Вам необходимо получить новую медицинскую карту или обновить имеющуюся?'},
				{0, u8'Для оформления медицинской карты предоставьте, пожалуйста, Ваш паспорт.'},
				{0, u8'/b Для этого введите /showpass {myid}'},
				{1, u8''},
				{0, u8'/me взял{sex:,а} паспорт из рук пациента и внимательно изучил{sex:,а} его'},
				{3, 1, 2, {u8'Новая мед. карта', u8'Обновить мед. карту'}},
				{8, '1', '1'},
				{0, u8'Стоимость оформления новой мед. карты зависит от её срока.'},
				{0, u8'7 дней: {med7}$. 14 дней: {med14}$'},
				{0, u8'30 дней: {med30}$. 60 дней: {med60}$'},
				{0, u8'Скажите на какой срок оформлять и мы продолжим.'},
				{3, 2, 4, {u8'7 дней', u8'14 дней', u8'30 дней', u8'60 дней'}},
				{8, '2', '1'},
				{5, '{var1}', '{med7}'},
				{5, '{var3}', '0'},
				{9, '1', '1'},
				{8, '2', '2'},
				{5, '{var1}', '{med14}'},
				{5, '{var3}', '1'},
				{9, '1', '1'},
				{8, '2', '3'},
				{5, '{var1}', '{med30}'},
				{5, '{var3}', '2'},
				{9, '1', '1'},
				{8, '2', '4'},
				{5, '{var1}', '{med60}'},
				{5, '{var3}', '3'},
				{9, '1', '1'},
				{9, ''},
				{8, '1', '2'},
				{0, u8'Стоимость обновления мед. карты зависит от её срока.'},
				{0, u8'7 дней: {medup7}$. 14 дней: {medup14}$'},
				{0, u8'30 дней: {medup30}$. 60 дней: {medup60}$'},
				{0, u8'Скажите на какой срок оформлять и мы продолжим.'},
				{3, 3, 4, {u8'7 дней', u8'14 дней', u8'30 дней', u8'60 дней'}},
				{8, '3', '1'},
				{5, '{var1}', '{medup7}'},
				{5, '{var3}', '0'},
				{9, '1', '1'},
				{8, '3', '2'},
				{5, '{var1}', '{medup14}'},
				{5, '{var3}', '1'},
				{9, '1', '1'},
				{8, '3', '3'},
				{5, '{var1}', '{medup30}'},
				{5, '{var3}', '2'},
				{9, '1', '1'},
				{8, '3', '4'},
				{5, '{var1}', '{medup60}'},
				{5, '{var3}', '3'},
				{9, '1', '1'},
				{9, '1', '1'},
				{0, u8'Хорошо, сейчас задам пару вопросов, отвечайте честно.'},
				{0, u8'Вы можете видеть имена проходящих мимо Вас людей?'},
				{1, ''},
				{0, u8'Вас когда-нибудь убивали?'},
				{3, 4, 4, {u8'Полностью здоров', u8'Наблюдаются откл.', u8'Псих. нездоров', u8'Неопределён'}},
				{8, '4', '1'},
				{5, '{var2}', '3'},
				{9, '1', '1'},
				{8, '4', '2'},
				{5, '{var2}', '2'},
				{9, '1', '1'},
				{8, '4', '3'},
				{5, '{var2}', '1'},
				{9, '1', '1'},
				{8, '4', '4'},
				{5, '{var2}', '0'},
				{9, '1', '1'},
				{0, u8'/me берёт в правую руку из мед. кейса печать и наносит штамп в углу бланка'},
				{0, u8'/do Печать больницы нанесена на бланк.'},
				{0, u8'/me кладёт печать в мед. кейс, после чего ручкой ставит подпись и сегодняшнюю дату'},
				{0, u8'/do Страница медицинской карты полностью заполнена.'},
				{0, u8'/me передаёт медицинскую карту в руки обратившемуся'},
				{0, u8'/medcard {arg1} {var2} {var3} {var1}'}
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 29},
			key = {},
			num_d = 5,
			rank = '3'
		}
		create_file_json('mc', u8'Оформить медицинскую карту', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'narko',
			var = {},
			act = {
				{0, u8'Очень замечательно, что Вы решили излечиться от наркозависимости.'},
				{0, u8'Стоимость одного сеанса составит {pricenarko}$'},
				{0, u8'Метод лечения современный, называется "Нейроочищение". Он полностью сотрёт информацию о наркотиках с Вашего мозга.'},
				{0, u8'Вы согласны? Если да, то ложитесь на кушетку и мы приступим.'},
				{1, ''},
				{0, u8'/do На столе лежат стерильные перчатки и медицинская маска.'},
				{0, u8'/me взяв со стола средства индивидуальной защиты, надел{sex:,а} их на себя'},
				{0, u8'/todo А теперь максимально расслабьтесь*подвигая спец. аппарат ближе к пациенту'},
				{0, u8'/me взял{sex:,а} шлем от аппарата, после чего надел{sex:,а} его на голову пациента'},
				{0, u8'/me включил{sex:,а} устройство, затем, подождав пять секунд, выключил{sex:,а} его'},
				{0, u8'/do Аппарат успешно завершил работу.'},
				{0, u8'/me снял{sex:,а} шлем с пациента и повесил{sex:,а} его обратно на аппарат'},
				{0, u8'/healbad {arg1}'},
				{0, u8'/todo Вот и всё! Тяга к запрещённым веществам должна исчезнуть*снимая с себя маску с перчатками'}
			},
			desc = u8'Вылечить от наркозависимости',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '4'
		}
		create_file_json('narko', u8'Вылечить от наркозависимости', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = u8'rec',
			var = {
			{1, '0'}
			},
			act = {
				{0, u8'Мы выписываем рецепты в ограниченном количестве.'},
				{0, u8'/n Не более 5 штук в минуту.'},
				{0, u8'Стоимость одного рецепта составляет {pricerecept}$'},
				{0, u8'Вы согласны? Если да, то какое количество Вам необходимо?'},
				{3, 1, 5, {u8'1 рецепт', u8'2 рецепта', u8'3 рецепта', u8'4 рецепта', u8'5 рецептов'}},
				{8, '1', '1'},
				{5, '{var1}', '1'},
				{9, '1', '1'},
				{8, '1', '2'},
				{5, '{var1}', '2'},
				{9, '1', '1'},
				{8, '1', '3'},
				{5, '{var1}', '3'},
				{9, '1', '1'},
				{8, '1', '4'},
				{5, '{var1}', '4'},
				{9, '1', '1'},
				{8, '1', '5'},
				{5, '{var1}', '5'},
				{9, '1', '1'},
				{0, u8'/do На столе лежат бланки для оформления рецептов.'},
				{0, u8'/me взяв ручку с печатью, заполнил{sex:,а} необходимые бланки, после чего поставил{sex:,а} печати в углу листа'},
				{0, u8'/do Все бланки рецептов успешно заполнены.'},
				{0, u8'/todo Держите и строго соблюдайте инструкцию!*передавая рецепты человеку напротив'},
				{0, u8'/recept {arg1} {var1}'}
			},
			desc = u8'Выписать рецепт',
			tr_fl = {0, 1, 5},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '4'
		}
		create_file_json('rec', u8'Выписать рецепт', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'osm',
			var = {},
			act = {
				{0, u8'Очень замечательно, что Вы решили пройти медицинский осмотр.'},
				{0, u8'Предоставьте мне, пожалуйста, Вашу медицинскую карту.'},
				{1, u8''},
				{0, u8'/me берёт медицинскую карту в руки и внимательно её изучает'},
				{0, u8'Давайте начнём. Снимите всю одежду, кроме нижнего белья.'},
				{1, u8''},
				{0, u8'/medcheck {arg1} {priceosm}'},
				{0, u8'/me внимательно осматривает пациента на наличие кожных заболеваний'},
				{0, u8'/todo Поздравляю! У Вас всё отлично!*заканчивая медицинский осмотр'},
				{0, u8'/do Медицинская карта находится в левой руке.'},
				{0, u8'/me достав ручку из кармана, {sex:внес,внесла} несколько изменений в медицинскую карту'},
				{0, u8'/me передал{sex:,а} медицинскую карту обратно в руки пациенту'},
				{0, u8'На этом всё. Всего Вам доброго, не болейте!'}
			},
			desc = u8'Провести медицинский осмотр',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '3'
		}
		create_file_json('osm', u8'Провести медицинский осмотр', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'tatu',
			var = {},
			act = {
				{0, u8'Сейчас мы начнём сеанс по выведению татуировки с Вашего тела.'},
				{0, u8'Покажите Ваш паспорт, пожалуйста.'},
				{1, ''},
				{0, u8'/me принял{sex:,а} с рук обратившегося паспорт'},
				{0, u8'/do Паспорт обратившегося в правой руке.'},
				{0, u8'/me ознакомившись с паспортом, вернул{sex:,а} его обратно владельцу'},
				{0, u8'Стоимость выведения татуировки составит {pricetatu}$. Вы согласны?'},
				{0, u8'/n Оплачивать не требуется, сервер сам предложит.'},
				{0, u8'/b Покажите татуировки с помощью команды /showtatu'},
				{1, ''},
				{0, u8'Я смотрю, Вы готовы, тогда снимайте с себя рубашку, чтобы я вывел{sex:,а} Вашу татуировку.'},
				{0, u8'/do У стены стоит инструментальный столик с подносом.'},
				{0, u8'/do Аппарат для выведения тату на подносе.'},
				{0, u8'/me взял{sex:,а} аппарат для выведения татуировки с подноса'},
				{0, u8'/me осмотрев пациента, принял{sex:ся,лась} выводить его татуировку'},
				{0, u8'/unstuff {arg1} {pricetatu}'}
			},
			desc = u8'Вывести татуировку с тела',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '7'
		}
		create_file_json('tatu', u8'Вывести татуировку с тела', add_table, '7')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'ant',
			var = {},
			act = {
				{0, u8'Насколько я понял{sex:,а}, Вам нужны антибиотики.'},
				{0, u8'Стоимость одного антибиотика составляет {priceant}$. Вы согласны?'},
				{0, u8'Если да, то какое количество Вам необходимо?'},
				{1, ''},
				{0, u8'/me открыв мед.сумку, схватил{sex:ась,ся} за пачку антибиотиков, после чего вытянул{sex:,а} их и положил на стол'},
				{0, u8'/do Антибиотики находятся на столе.'},
				{0, u8'/todo Вот держите, употребляйте их строго по рецепту!*закрывая мед. сумку'},
				{2, u8'Введите количество антибиотиков в чат.'},
				{0, u8'/antibiotik {arg1} '}
			},
			desc = u8'Выписать антибиотики',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '4'
		}
		create_file_json('ant', u8'Выписать антибиотики', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'cur',
			var = {},
			act = {
				{0, u8'/me легким движением пальца прислонил{sex:,а} к шее пациента, после чего начал{sex:,а} измерять пульс'},
				{0, u8'/do У пациента отсутствует пульс.'},
				{0, u8'/todo Нужно быстро принять меры!*посмотрев на мед. сумку'},
				{0, u8'/me легким движением руки открыл{sex:,а} мед. сумку, после чего достал{sex:,а} платок'},
				{0, u8'/me аккуратно приложил{sex:,а} платок ко рту пострадавшего, после чего сделал{sex:,а} глубокий вдох'},
				{0, u8'/do В лёгких много воздуха.'},
				{0, u8'/me встал{sex:,а} на колени, после чего прислонил{sex:ся,ась} к пациенту'},
				{0, u8'/me {sex:подвел,подвела} губы ко рту пострадавшего, после чего начал{sex:,а} делать искусственное дыхание'},
				{0, u8'/me отвел{sex:,а} губы от рта пострадавшего, после чего сделал{sex:,а} глубокий вдох'},
				{0, u8'/me подвел{sex:,а} губы ко рту пострадавшего, после чего начал{sex:,а} делать искусственное дыхание'},
				{0, u8'/do Пациент очнулся.'},
				{0, u8'/cure {arg1}'}
			},
			desc = u8'Поднять человека присмерти',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '2'
		}
		create_file_json('cur', u8'Поднять человека присмерти', add_table, '2')
		
		setting.fast_acc.sl = {
			{
				text = u8'Вылечить',
				cmd = 'hl',
				pass_arg = true,
				send_chat = true
			},
			{
				send_chat = true,
				cmd = 'mc',
				pass_arg = true,
				text = u8'Оформить мед. карту'
			},
			{
				send_chat = true,
				cmd = 'osm',
				pass_arg = true,
				text = u8'Мед. осмотр'
			},
			{
				text = u8'Излечить от нарко',
				cmd = 'narko',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Выдать рецепт',
				cmd = 'rec',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Выписать антибиотики',
				cmd = 'ant',
				pass_arg = true,
				send_chat = true
			},
			{
				send_chat = true,
				cmd = 'cur',
				pass_arg = true,
				text = u8'Поднять при смерти'
			},
			{
				send_chat = true,
				cmd = 'z',
				pass_arg = true,
				text = u8'Поздароваться'
			},
			{
				send_chat = true,
				cmd = 'za',
				pass_arg = true,
				text = u8'Пройдёмте за мной'
			},
			{
				text = u8'Выгнать',
				cmd = 'exp',
				pass_arg = true,
				send_chat = false
			}
		}
		save('setting')
	elseif org_to_replace:find(u8'Центр Лицензирования') then
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licmauto',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию на вождение автомобиля',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц 100.000$, на 2 месяца 160.000$, на 3 месяца 210.000$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на авто'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[0][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '1'
		}
		create_file_json('licauto', u8'Продать лицензию на вождение автомобиля', add_table, '1')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licmoto',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию на вождение мотоцикла',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц 150.000$, на 2 месяца 200.000$, на 3 месяца 240.000$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на мото'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[1][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '2'
		}
		create_file_json('licmoto', u8'Продать лицензию на вождение мотоцикла', add_table, '2')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licfly',
			var = {{1, '0'}},
			tr_fl = {0, 0, 0},
			desc = u8'Продать лицензию на полёты',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии составляет 500.000$. Вы согласны?'},
				{1, u8''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на полёты'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[2][0][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '7'
		}
		create_file_json('licfly', u8'Продать лицензию на полёты', add_table, '7')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licfish',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию на рыболовство',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц 200.000$, на 2 месяца 250.000$, на 3 месяца 290.000$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на рыболовство'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[3][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '3'
		}
		create_file_json('licfish', u8'Продать лицензию на рыболовство', add_table, '3')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licswim',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию на водный транспорт',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц 200.000$, на 2 месяца 250.000$, на 3 месяца 290.000$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на вод. транспорт'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[4][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '4'
		}
		create_file_json('licswim', u8'Продать лицензию на водный транспорт', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'licgun',
			var = {
				{1, '0'}
			},
			tr_fl = {0, 2, 8},
			desc = u8'Продать лицензию на оружие',
			act = {
				{0, u8'Для оформления лицензии на оружие, мне нужно убедиться, что Вы здоровы.'},
				{0, u8'Покажите, пожалуйста, Вашу медицинскую карту.'},
				{0, u8'/n /showmc {myid}'},
				{3, 1, 3, {u8'Здоров', u8'Имеются отклонения', u8'Нет мед. карты'}},
				{8, '1', '1'},
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц 240.000$, на 2 месяца 330.000$, на 3 месяца 405.000$'},
				{0, u8'На какой срок оформляем?'},
				{3, 2, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '2', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '2', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '2', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на оружие'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[5][{var1}][{arg1}]}'},
				{9, ''},
				{8, '1', '2'},
				{0, u8'Извините, но я не могу оформить Вам лицензию на оружие в связи с состоянием здоровья.'},
				{0, u8'Вы можете снова пройти мед. обследование в больнице и вернуться к нам.'},
				{9, ''},
				{8, '1', '3'},
				{0, u8'Извините, но сейчас я не могу оформить Вам лицензию на оружие.'},
				{0, u8'У Вас отсутствует медицинская карта. Оформить её можно в ближайшей больнице.'},
				{9, ''}
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 3,
			rank = '5'
		}
		create_file_json('licgun', u8'Продать лицензию на оружие', add_table, '5')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'lichunt',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию на охоту',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц 230.000$, на 2 месяца 330.000$, на 3 месяца 390.000$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на охоту'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[6][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '5'
		}
		create_file_json('lichunt', u8'Продать лицензию на охоту', add_table, '5')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licdig',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию на раскопки',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц 230.000$, на 2 месяца 330.000$, на 3 месяца 390.000$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на раскопки'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[7][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '6'
		}
		create_file_json('licdig', u8'Продать лицензию на раскопки', add_table, '6')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'lictaxi',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию для работы в такси',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц 500.000$, на 2 месяца 750.000$, на 3 месяца 1.000.000$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на такси'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[8][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '6'
		}
		create_file_json('lictaxi', u8'Продать лицензию для работы в такси', add_table, '6')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licmec',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию для работы на механика',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц 500.000$, на 2 месяца 750.000$, на 3 месяца 1.000.000$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на механика'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[9][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '6'
		}
		create_file_json('licmec', u8'Продать лицензию на механика', add_table, '6')
		
		setting.fast_acc.sl = {
			{
				text = u8'Лицензия на авто',
				cmd = 'licauto',
				pass_arg = true,
				send_chat = true
			},
			{
				send_chat = true,
				cmd = 'licmoto',
				pass_arg = true,
				text = u8'Лицензия на мото'
			},
			{
				text = u8'Лицензия на рыбу',
				cmd = 'licfish',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Лицензия на плавание',
				cmd = 'licswim',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Лицензия на оружие',
				cmd = 'licgun',
				pass_arg = true,
				send_chat = true
			},
			{
				send_chat = true,
				cmd = 'lichunt',
				pass_arg = true,
				text = u8'Лицензия на охоту'
			},
			{
				send_chat = true,
				cmd = 'licdig',
				pass_arg = true,
				text = u8'Лицензия на раскопки'
			},
			{
				send_chat = true,
				cmd = 'lictaxi',
				pass_arg = true,
				text = u8'Лицензия на такси'
			},
			{
				send_chat = true,
				cmd = 'licmec',
				pass_arg = true,
				text = u8'Лицензия на механика'
			},
			{
				send_chat = true,
				cmd = 'licfly',
				pass_arg = true,
				text = u8'Лицензия на полёты'
			},
			{
				send_chat = true,
				cmd = 'z',
				pass_arg = true,
				text = u8'Поздароваться'
			},
			{
				text = u8'Выгнать',
				cmd = 'exp',
				pass_arg = true,
				send_chat = false
			}
		}
		save('setting')
	elseif org_to_replace:find(u8'Центральный Банк') then
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'finddep',
			var = {},
			rank = '1',
			tr_fl = {0, 0, 0},
			desc = u8'Узнать долг банку',
			act = {
				{0, u8'/me открыл{sex:,а} на компьютере базу данных банка и наш{sex:ел,ла} там необходимого клиента'},
				{0, u8'/me нажал{sex:,а} на кнопку печати, после чего передал{sex:,а} лист с информацией человеку напротив'},
				{0, u8'{dialogbank[1][{arg1}]}'}
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('finddep', u8'Узнать долг банку', add_table, '1')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'lmoney',
			var = {},
			rank = '1',
			act = {
				{0, u8'/me открыл{sex:,а} на компьютере базу данных банка и наш{sex:ел,ла} там необходимого клиента'},
				{0, u8'/me нажал{sex:,а} на кнопку печати, после чего передал{sex:,а} лист с информацией человеку напротив'},
				{0, u8'{dialogbank[2][{arg1}]}'}
			},
			desc = u8'Узнать количество денег в банке',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('lmoney', u8'Узнать количество денег в банке', add_table, '1')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'newcard',
			var = {},
			rank = '1',
			tr_fl = {0, 0, 0},
			desc = u8'Оформить банковскую карту',
			act = {
				{0, u8'Для оформления банковской карты необходимо предоставить паспорт.'},
				{0, u8'/n /showpass {myid}'},
				{1, ''},
				{0, u8'/me берет паспорт, раскрывает его и начинает вводить информацию в компьютер'},
				{0, u8'/todo Осталось лишь придумать пароль*передавая терминал человеку напротив'},
				{0, u8'/me сохраняет данные о банковской карте в компьютер'},
				{0, u8'/todo Всё готово!*передавая паспорт обратно клиенту'},
				{0, u8'{dialogbank[3][{arg1}]}'}
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('newcard', u8'Оформить банковскую карту', add_table, '1')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'rescard',
			var = {},
			rank = '1',
			act = {
				{0, u8'Стоимость восстановления пин-кода от банковской карты составляет 30.000$.'},
				{0, u8'Для оказания такой услуги мне необходим Ваш паспорт.'},
				{0, u8'/n /showpass {myid}'},
				{1, ''},
				{0, u8'/me берёт паспорт, раскрывает его и начинает вводить информацию в компьютер'},
				{0, u8'/me вбивает паспортные данные в систему и вносит изменения в личное дело'},
				{0, u8'/todo Всё готово! Пин-код от карты придет Вам в виде СМС через пару минут*улыбаясь'},
				{0, u8'{dialogbank[4][{arg1}]}'}
			},
			desc = u8'Сменить пин-код банковской карты',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('rescard', u8'Сменить пин-код банковской карты', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			desc = u8'Снять деньги с депозита',
			nm = 'undep',
			var = {},
			rank = '3',
			act = {
				{0, u8'/me берет паспорт, раскрывает его и начинает вводить информацию в компьютер'},
				{0, u8'/me вбивает паспортные данные в систему и вносит изменения в личное дело'},
				{0, u8'/me закрывает паспорт и возвращает владельцу'},
				{0, u8'/todo Вот Ваш паспорт, спасибо, что пользуетесь нашими услугами*слегка улыбнувшись'},
				{0, u8'{dialogbank[5][{arg1}]}'}
			},
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('undep', u8'Снять деньги с депозита', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'vipcard',
			var = {},
			rank = '3',
			act = {
				{0, u8'/me открыл{sex:,а} на компьютере базу данных банка и наш{sex:ел,ла} там необходимого клиента'},
				{0, u8'/me установил{sex:,а} клиенту VIP статус в базе данных банка, после чего передал{sex:,а} ему VIP карту'},
				{0, u8'/todo Осталось оплатить и можно пользоваться!*передавая клиенту квитанцию оплаты'},
				{0, u8'{dialogbank[8][{arg1}]}'}
			},
			desc = u8'Оформить карту VIP клиента',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('vipcard', u8'Оформить карту VIP клиента', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'repdep',
			var = {},
			rank = '4',
			act = {
				{0, u8'/me открывает базу данных банка на компьютере, после чего выставляет клиенту счёт'},
				{0, u8'/me нажав на кнопку печати, забирает квитанцию с принтера и передаёт её человеку напротив'},
				{0, u8'{dialogbank[6][{arg1}]}'}
			},
			desc = u8'Пополнить деньги на депозит',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('repdep', u8'Пополнить деньги на депозит', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'kwdep',
			var = {},
			rank = '4',
			tr_fl = {0, 0, 0},
			desc = u8'Узнать, когда можно снять деньги с депозита',
			act = {
				{0, u8'/me открыв базу данных на компьютере, наш{sex:ел,ла} необходимого клиента'},
				{0, u8'/me нажав на кнопку печати, забирает листок с принтера и передаёт его человеку напротив'},
				{0, u8'{dialogbank[7][{arg1}]}'}
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('kwdep', u8'Узнать, когда можно снять деньги с депозита', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'addacc',
			var = {},
			rank = '4',
			act = {
				{0, u8'Стоимость дополнительного счета составляет 30.000.000$, мне потребуется Ваш паспорт.'},
				{0, u8'/n /showpass {myid}'},
				{1, ''},
				{0, u8'/me берёт паспорт, раскрывает его и начинает вводить информацию в базу данных банка'},
				{0, u8'/me вбивает паспортные данные в систему и нажимает на кнопку "Дополнительный счёт"'},
				{0, u8'/me выходит из системы и возвращает паспорт клиенту'},
				{0, u8'{dialogbank[9][{arg1}]}'}
			},
			desc = u8'Открыть дополнительный личный счёт',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('addacc', u8'Открыть дополнительный личный счёт', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'penacc',
			var = {},
			rank = '4',
			act = {
				{0, u8'Для начала мне потребуется Ваш паспорт.'},
				{0, u8'/n /showpass {myid}'},
				{1, ''},
				{0, u8'/me берёт паспорт, раскрывает его и начинает вводить информацию в базу данных банка'},
				{0, u8'/me вбивает паспортные данные в систему и нажимает на кнопку "Пенсионный счёт"'},
				{0, u8'/me выходит из системы и возвращает паспорт клиенту'},
				{0, u8'{dialogbank[10][{arg1}]}'}
			},
			desc = u8'Открыть пенсионный счёт',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('penacc', u8'Открыть пенсионный счёт', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'pentake',
			var = {},
			rank = '4',
			act = {
				{0, u8'/me берет паспорт, раскрывает его и начинает вводить информацию в компьютер'},
				{0, u8'/me вбивает паспортные данные в систему и вносит изменения в личное дело'},
				{0, u8'/me закрывает паспорт и возвращает владельцу'},
				{0, u8'/todo Вот Ваш паспорт, спасибо, что пользуетесь нашими услугами*слегка улыбнувшись'},
				{0, u8'{dialogbank[11][{arg1}]}'}
			},
			desc = u8'Снять деньги с пенсионного счёта',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('pentake', u8'Снять деньги с пенсионного счёта', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'givecredit',
			var = {},
			rank = '6',
			act = {
				{0, u8'Чтобы получить кредит, Вы не должны иметь проблем с законом и иметь хорошую ...'},
				{0, u8'... кредитную историю. Если Вы согласны, то прошу Вас передать мне свой паспорт.'},
				{0, u8'/n /showpass {myid}'},
				{1, ''},
				{0, u8'/me берет паспорт, раскрывает его и начинает вводить информацию в компьютер'},
				{0, u8'/me вбивает паспортные данные в систему и вносит изменения в личное дело'},
				{0, u8'/me закрывает паспорт и возвращает владельцу'},
				{0, u8'/todo Вот ваш паспорт, спасибо, что пользуетесь нашими услугами*слегка улыбнувшись'},
				{0, u8'{dialogbank[0][{arg1}]}'}
			},
			desc = u8'Оформить кредит',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('givecredit', u8'Оформить кредит', add_table, '6')
		
		setting.fast_acc.sl = {
			{
				text = u8'Узнать долг',
				cmd = 'finddep',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Узнать сумму в банке',
				cmd = 'lmoney',
				pass_arg = true,
				send_chat = true
				
			},
			{
				text = u8'Оформить карту',
				cmd = 'newcard',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Сменить ПИН-код',
				cmd = 'rescard',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Снять с депозита',
				cmd = 'undep',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Оформить VIP карту',
				cmd = 'vipcard',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Пополнить депозит',
				cmd = 'repdep',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Когда можно снять деньги',
				cmd = 'kwdep',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Открыть доп. счёт',
				cmd = 'addacc',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Открыть пенсионный',
				cmd = 'penacc',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Снять с пенсионного',
				cmd = 'pentake',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Оформить кредит',
				cmd = 'givecredit',
				pass_arg = true,
				send_chat = true
			},
			{
				send_chat = true,
				cmd = 'z',
				pass_arg = true,
				text = u8'Поздароваться'
			},
			{
				text = u8'Выгнать',
				cmd = 'exp',
				pass_arg = true,
				send_chat = false
			}
		}
		save('setting')
	end
end

function hook.onServerMessage(mes_color, mes)
	if setting.chat_pl then
		if mes:find('Объявление:') or mes:find('Отредактировал сотрудник') then
			return false
		end
	end
	if setting.chat_smi then
		if mes:find('News LS') or mes:find('News SF') or mes:find('News LV') then 
			return false
		end
	end
	if setting.chat_help then
		if mes:find('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~') or mes:find('- Основные команды сервера: /menu /help /gps /settings') 
		or mes:find('Пригласи друга и получи бонус в размере') or mes:find('- Донат и получение дополнительных средств arizona-rp.com/donate') 
		or mes:find('Подробнее об обновлениях сервера') or mes:find('(Личный кабинет/Донат)') or mes:find('С помощью телефона можно заказать') 
		or mes:find('В нашем магазине ты можешь') or mes:find('их на желаемый тобой {FFFFFF}бизнес') or mes:find('Игроки со статусом {FFFFFF}VIP{6495ED} имеют большие возможности') 
		or mes:find('можно приобрести редкие {FFFFFF}автомобили, аксессуары, воздушные') or mes:find('предметы, которые выделят тебя из толпы! Наш сайт:') 
		or mes:find('Вы можете купить складское помещение') or mes:find('Таким образом вы можете сберечь своё имущество, даже если вас забанят.') 
		or mes:find('Этот тип недвижимости будет навсегда закреплен за вами и за него не нужно платить.') or mes:find('{ffffff}Уважаемые жители штата, открыта продажа билетов на рейс:') 
		or mes:find('{ffffff}Подробнее: {FF6666}/help — Перелёты в город Vice City.') or mes:find('{ffffff}Внимание! На сервере Vice City действует акция Х3 PayDay.') 
		or mes:find('%[Подсказка%] Игроки владеющие (.+) домами могут бесплатно раз в день получать') or mes:find('%[Подсказка%] Игроки владеющие (.+) домами могут получать (.+) Ларца Олигарха') then 
			return false
		end
	end
	if mes:find('Администратор ((%w+)_(%w+)):(.+)спавн') or mes:find('Администратор (%w+)_(%w+):(.+)Спавн') then
		if setting.notice.car and not error_spawn then
			lua_thread.create(function()
				error_spawn = true
				local stop_signal = 0
				repeat wait(200) 
					addOneOffSound(0, 0, 0, 1057)
					stop_signal = stop_signal + 1
				until stop_signal > 17
				wait(62000)
				error_spawn = false
			end)
		end
	end
	if (mes:find('%[D%](.+)'..u8:decode(setting.dep.my_tag)..'(.+)связь') and setting.notice.dep) or (mes:find('%[D%](.+)'..u8:decode(setting.dep.my_tag_en)..'(.+)связь') and setting.notice.dep and setting.dep.my_tag_en ~= '') then
		local comparison = mes:match('%[(%d+)%]')
		comparison = tonumber(comparison)
		lua_thread.create(function()
			wait(15)
			EXPORTS.sendRequest()
			wait(200)
			local found_our = false
			for i, member in ipairs(members) do
				if tonumber(member.id) == comparison then
					found_our = true
					break
				end
			end
			if not found_our then
				sampAddChatMessage(script_tag..'{e3a220}Вашу организацию вызывают в рации департамента!', color_tag)
				sampAddChatMessage(script_tag..'{e3a220}Вашу организацию вызывают в рации департамента!', color_tag)
				local stop_signal = 0
				repeat wait(200) 
					addOneOffSound(0, 0, 0, 1057)
					stop_signal = stop_signal + 1
				until stop_signal > 17
			end
		end)
	end
	if setting.show_dialog_auto then
		if mes:find('%[Новое предложение%]{ffffff} Вам поступило предложение от игрока(.+)%. Используйте команду%: %/offer или клавишу X') then
			sampSendChat('/offer')
		end
	end
	if select_main_menu[4] then
		if mes:find('^%[D%](.+)%[(%d+)%]:') then
			local bool_t = imgui.ImBuffer(92)
			bool_t.v = mes
			table.insert(dep_history, bool_t.v)
			if bool_t.v ~= mes then
				local icran = bool_t.v:gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%.', '%%.'):gsub('%-', '%%-'):gsub('%+', '%%+'):gsub('%?', '%%?'):gsub('%$', '%%$'):gsub('%*', '%%*'):gsub('%(', '%%('):gsub('%)', '%%)')
				bool_t.v = mes:gsub(icran, '')
				table.insert(dep_history, bool_t.v)
			end
		end
	elseif select_main_menu[5] and sobes_menu then
		if mes:find(my.nick..'%['..my.id..'%]') or mes:find(pl_sob.nm..'%['..pl_sob.id..'%]') then
			local bool_t = imgui.ImBuffer(98)
			local ch_end_f
			if setting.int.theme ~= 'White' then
				ch_end_f = mes
			else
				ch_end_f = mes:gsub('%{B7AFAF%}', '%{464d4f%}'):gsub('%{FFFFFF%}', '%{464d4f%}')
			end
			bool_t.v = ch_end_f
			table.insert(sob_history, bool_t.v)
			if bool_t.v ~= ch_end_f then
				local icran = bool_t.v:gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%.', '%%.'):gsub('%-', '%%-'):gsub('%+', '%%+'):gsub('%?', '%%?'):gsub('%$', '%%$'):gsub('%*', '%%*'):gsub('%(', '%%('):gsub('%)', '%%)')
				bool_t.v = ch_end_f:gsub(icran, '')
				table.insert(sob_history, bool_t.v)
			end
		end
	end
	if mes:find('Организационная зарплата: $(%d+)') then
		local mes_pay = mes:match('Организационная зарплата: $(.+)'):gsub('%D', '')
		if setting.frac.org:find(u8'Больница') then
			setting.stat.hosp.total_all = setting.stat.hosp.total_all + tonumber(mes_pay)
			setting.stat.hosp.payday[1] = setting.stat.hosp.payday[1] + tonumber(mes_pay)
		end
		save('setting')
	end
	if mes:find('%[Информация%] {FFFFFF}Вы вылечили (.+) за ') then
		local mes_pay = mes:match('$(.+)'):gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + round(tonumber(mes_pay) * 0.6, 1)
		setting.stat.hosp.lec[1] = setting.stat.hosp.lec[1] + round(tonumber(mes_pay) * 0.6, 1)
		save('setting')
	end
	if mes:find('%[Информация%] {FFFFFF}Вы выдали (.+) сроком') then
		local mes_pay = mes:match(' на (%d+)')
		local money_med = tonumber(setting.price.mede[1])
		if tonumber(mes_pay) == 14 then
			money_med = tonumber(setting.price.mede[2])
		elseif tonumber(mes_pay) == 30 then
			money_med = tonumber(setting.price.mede[3])
		elseif tonumber(mes_pay) == 60 then
			money_med = tonumber(setting.price.mede[4])
		end
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + round(money_med / 2, 1)
		setting.stat.hosp.medcard[1] = setting.stat.hosp.medcard[1] + round(money_med / 2, 1)
		save('setting')
	end
	if mes:find('%[Информация%] {FFFFFF}Вы начали лечение (.+) от наркозависимости за ') then
		local mes_pay = mes:match('%$(.+)'):gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + (tonumber(mes_pay) * 0.8)
		setting.stat.hosp.apt[1] = setting.stat.hosp.apt[1] + (tonumber(mes_pay) * 0.8)
		save('setting')
	end
	if mes:find('%[Информация%] {FFFFFF}Вы продали антибиотики (.+) игроку (.+) за (.+)ваша') then
		local mes_pay = mes:match('прибыль: $(.+)'):gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + tonumber(mes_pay)
		setting.stat.hosp.ant[1] = setting.stat.hosp.ant[1] + tonumber(mes_pay)
		save('setting')
	end
	if mes:find('%[Информация%] {FFFFFF}Вы продали (%d+) рецептов (.+) за ') then
		local mes_pay = mes:match('%$(.+)'):gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + round(tonumber(mes_pay) / 2, 1)
		setting.stat.hosp.rec[1] = setting.stat.hosp.rec[1] + round(tonumber(mes_pay) / 2, 1)
		save('setting')
	end
	if sampGetGamestate() == 3 then
		if mes:find('>>>{FFFFFF} '..my.nick..'%[(%d+)%] доставил 100 медикаментов на склад больницы!') then
			setting.stat.hosp.total_all = setting.stat.hosp.total_all + 100000
			setting.stat.hosp.medcam[1] = setting.stat.hosp.medcam[1] + 100000
			save('setting')
		end
	end
	if mes:find('Вы поставили на ноги игрока (.+)') then
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + 300000
		setting.stat.hosp.cure[1] = setting.stat.hosp.cure[1] + 300000
		save('setting')
	end
	if mes:find('%[Информация%] %{FFFFFF%}Вы предложили (.+) купить лицензию(.+)') then
		local price_lic_i = mes:match(' за %$(%d+)')
		price_lic = tonumber(price_lic_i) / 2
	end
	if mes:find('%[Информация%] {FFFFFF}Вы успешно продали лицензию') then
		local lic_type = mes:match('%[Информация%] {FFFFFF}Вы успешно продали лицензию (.+) игроку')
		if lic_type == 'авто' then
			setting.stat.school.auto[1] = setting.stat.school.auto[1] + price_lic
		elseif lic_type == 'мото' then
			setting.stat.school.moto[1] = setting.stat.school.moto[1] + price_lic
		elseif lic_type == 'на рыбалку' then
			setting.stat.school.fish[1] = setting.stat.school.fish[1] + price_lic
		elseif lic_type == 'на плавание' then
			setting.stat.school.swim[1] = setting.stat.school.swim[1] + price_lic
		elseif lic_type == 'на оружие' then
			setting.stat.school.gun[1] = setting.stat.school.gun[1] + price_lic
		elseif lic_type == 'на охоту' then
			setting.stat.school.hun[1] = setting.stat.school.hun[1] + price_lic
		elseif lic_type == 'на раскопки' then
			setting.stat.school.exc[1] = setting.stat.school.exc[1] + price_lic
		elseif lic_type == 'таксиста' then
			setting.stat.school.taxi[1] = setting.stat.school.taxi[1] + price_lic
		elseif lic_type == 'механика' then
			setting.stat.school.meh[1] = setting.stat.school.meh[1] + price_lic
		end
		setting.stat.school.total_all = setting.stat.school.total_all + price_lic
		save('setting')
	end
	if mes:find('AIberto_Kane(.+):(.+)vizov1488sh') or mes:find('Alberto_Kane(.+):(.+)vizov1488sh') then
		if mes:find('AIberto_Kane(.+){B7AFAF}') or mes:find('Alberto_Kane(.+){B7AFAF}') then
			local rever = 0
			sampShowDialog(2001, 'Подтверждение', 'Это сообщение говорит о том, что к Вам обращается официальный\n                 разработчик скрипта State Helper - {2b8200}Alberto_Kane', 'Закрыть', '', 0)
			sampAddChatMessage(script_tag..'Это сообщение подтверждает, что к Вам обращается разработчик State Helper - {39e3be}Alberto_Kane.', 0xFF5345)
			lua_thread.create(function()
				repeat wait(200)
					addOneOffSound(0, 0, 0, 1057)
					rever = rever + 1
					until rever > 10
			end)
			return false
		end
	end
	if mes:find('Вы не можете продавать лицензии на такой срок') then
		num_give_lic = -1
		sampAddChatMessage(script_tag..'{FFFFFF}Ваш ранг не позволяет выдать эту лицензию!', 0xFF5345)
		return false
	end
end

--> Проверка обновлений
function update_check()
	upd_status = 1
	local upd_txt_info = 'https://raw.githubusercontent.com/KaneScripter/StateHelper/main/Информация.json'
	local dir = dirml..'/StateHelper/Для обновления/Информация.json'
	downloadUrlToFile(upd_txt_info, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			lua_thread.create(function()
				wait(2500)
				if doesFileExist(dirml..'/StateHelper/Для обновления/Информация.json') then
					local f = io.open(dirml..'/StateHelper/Для обновления/Информация.json', 'r')
					upd = decodeJson(f:read('*a'))
					f:close()
					
					local new_version = upd.version:gsub('%D', '')
					if tonumber(new_version) > scr_version then
						download_id = downloadUrlToFile(upd.image, getWorkingDirectory()..'/StateHelper/Изображения/Новая версия.png', function(id, status, p1, p2)
							if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
								IMG_New_Version = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Новая версия.png')
								upd_status = 2
								if not setting.auto_update then
									addOneOffSound(0, 0, 0, 1058)
									sampAddChatMessage(script_tag..'{FFFFFF}Доступно обновление. Обновиться можно через настройки скрипта.', color_tag)
								else
									addOneOffSound(0, 0, 0, 1058)
									sampAddChatMessage(script_tag..'{FFFFFF}Скачивание обновления...', color_tag)
									update_download()
								end
							end
						end)
					else
						upd_status = 0
					end
				end
			end)
		end
	end)
end

--> Скачивание обновления
function update_download()
	local dir = dirml..'/StateHelper.lua'
	lua_thread.create(function()
		wait(2000)
		downloadUrlToFile(url_upd, dir, function(id, status, p1, p2)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if updates == nil then 
					print('{FF0000}Ошибка при попытке скачать файл.') 
					addOneOffSound(0, 0, 0, 1058)
					sampAddChatMessage(script_tag..'{FFFFFF}Произошла неизвестная ошибка при скачивании обновления.', color_tag)
					lua_thread.create(function()
						wait(500)
						update_error()
					end)
				end
			end
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				updates = true
				print('Загрузка завершена успешно.')
				sampAddChatMessage(script_tag..'{FFFFFF}Скачивание успешно завершено! Перезагрузка скрипта...', color_tag)
				setting.int.first_start = false
				save('setting')
				showCursor(false)
				reloadScripts()
				showCursor(false)
			end
		end)
	end)
end

function update_error()
local erTx =
[[
{FFFFFF}Похоже, что-то мешает скачиванию обновлению.
Это может быть как антивирус, так и анти-стиллер, который блокирует скачивание.
Если у Вас отключен антивирус, отсутствует анти-стиллер, то видимо что-то другое
блокирует скачивание. Поэтому нужно будет скачать файл отдельно.

Пожалуйста, обратитесь к разработчику скрипта ВКонтакте.
Страницу можно найти, перейдя по ссылке:
{A1DF6B}vk.com/marseloy{FFFFFF}
Скачайте lua файл и переместите с заменой в папку moonloader.

Ссылка на страницу ВКонтакте уже скопирована автоматически.
]]
sampShowDialog(2001, '{FF0000}Ошибка обновления', erTx, 'Закрыть', '', 0)
setClipboardText('vk.com/marseloy')
end

--> Фильтр текста
function filter(mode, filder_char)
	local function locfil(data)
		if mode == 0 then 
			if string.char(data.EventChar):find(filder_char) then 
				return true
			end
		elseif mode == 1 then
			if not string.char(data.EventChar):find(filder_char) then 
				return true
			end
		end
	end 
	
	local cb_filter = imgui.ImCallback(locfil)
	return cb_filter
end

--> Мемберс (Cosmo)
members = {}
cloth = false
lastDialogWasActive = 0
dont_show_me_members = false
script_cursor = false
fontes = renderCreateFont('Trebuchet MS', setting.members.size, setting.members.flag)
members_wait = {
	members = false,
	next_page = {
		bool = false,
		i = 0
	}
}
org = {
	name = 'Организация',
	online = 0,
	afk = 0
}

function hook.onShowDialog(id, style, title, but_1, but_2, text)
	if id == 2015 and members_wait.members then
		local ip, port = sampGetCurrentServerAddress()
        local server = ip..':'..port
		if server == '80.66.82.147:7777' then return false end
		local count = 0
		members_wait.next_page.bool = false
		if title:find('{FFFFFF}(.+)%(В сети: (%d+)%)') then
			org.name, org.online = title:match('{FFFFFF}(.+)%(В сети: (%d+)%)')
			if org.name:find('Больница LS') then
				pers.frac.org = 'Больница ЛС'
				num_of_the_selected_org = 1
			elseif org.name:find('Больница LV') then
				pers.frac.org = 'Больница ЛВ'
				num_of_the_selected_org = 2
			elseif org.name:find('Больница SF') then
				pers.frac.org = 'Больница СФ'
				num_of_the_selected_org = 3
			elseif org.name:find('Больница Jefferson') then
				pers.frac.org = 'Больница Джефферсон'
				num_of_the_selected_org = 4
			elseif org.name:find('Центр лицензирования') then
				pers.frac.org = 'Центр Лицензирования'
				num_of_the_selected_org = 5
			elseif org.name:find('Центральный Банк') then
				pers.frac.org = 'Центральный Банк'
				num_of_the_selected_org = 6
			else
				pers.frac.org = org.name
				num_of_the_selected_org = 0
			end
		else
			org.name = 'Больница VC'
			pers.frac.org = 'Больница ВС'
			org.online = title:match('%(В сети: (%d+)%)')
		end
		for line in text:gmatch('[^\r\n]+') do
    		count = count + 1
    		if not line:find('Ник') and not line:find('страница') then
    			local color = string.match(line, '^{(%x+)}')
				local nick, id, rank_name, rank_id, warns, afk, quests = string.match(line, '([A-z_0-9]+)%((%d+)%)\t(.+)%((%d+)%)\t(%d+) %((%d+).+\t(%d+)')
				local uniform = (color == 'FFFFFF')
	    		members[#members + 1] = { 
					nick = tostring(nick),
					id = id,
					rank = {
						count = tonumber(rank_id),
					},
					afk = tonumber(afk),
					warns = tonumber(warns),
					rank_name = rank_name,
					uniform = uniform
				}
			end

    		if line:match('Следующая страница') then
    			members_wait.next_page.bool = true
    			members_wait.next_page.i = count - 2
    		end
    	end

    	if members_wait.next_page.bool then
    		sampSendDialogResponse(id, 1, members_wait.next_page.i, _)
    		members_wait.next_page.bool = false
    		members_wait.next_page.i = 0
    	else
    		while #members > tonumber(org.online) do 
    			table.remove(members, 1) 
    		end
    		sampSendDialogResponse(id, 0, _, _)
			org.afk = getAfkCount()
    		members_wait.members = false
    	end
		for i, member in ipairs(members) do
			if members[i].nick == my.nick and members[i].uniform == true then
				cloth = members[i].uniform
				pers.frac.title = u8(members[i].rank_name)
				pers.frac.rank = u8(members[i].rank.count)
				setting.frac.rank = pers.frac.rank
				setting.frac.title = pers.frac.title
			end
		end
		save('setting')
		return false
	elseif members_wait.members and id ~= 2015 then
		dont_show_me_members = true
		members_wait.members = false
		members_wait.next_page.bool = false
    	members_wait.next_page.i = 0
    	while #members > tonumber(org.online) do 
			table.remove(members, 1) 
		end 
	elseif dont_show_me_members and id == 2015 then
		dont_show_me_members = false
		lua_thread.create(function(); wait(0)
			sampSendDialogResponse(id, 0, nil, nil)
		end)
		return false
	end
	if id == 131 and healme then
		healme = false
		sampSendDialogResponse(131, 1)
		return false
	elseif healme then
		healme = false
	end
	if id == 26365 and num_give_lic > -1 then
		sampSendDialogResponse(26365, 1, num_give_lic, nil)
		return false
	end
	if id == 26366 and num_give_lic > -1 then
		sampSendDialogResponse(26366, 1, num_give_lic_term, nil)
		num_give_lic = -1
		return false
	end
	if id == 25693 and setting.show_dialog_auto then
		local g = 0
		for line in text:gmatch('[^\r\n]+') do
			if line:find('медицинскую') or line:find('паспорт') or line:find('лицензии') then
				sampSendDialogResponse(25693, 1, g, nil)
				g = g + 1
			end
		end
	end
	if id == 25694 and setting.show_dialog_auto then
		for line in text:gmatch('[^\r\n]+') do
			if line:find('медицинскую') or line:find('паспорт') or line:find('лицензии') then
				sampSendDialogResponse(25694, 1, 5, nil)
			end
		end
		
	end
	if id == 1234 and sobes_menu then
		if title:find('Мед%. карта') and text:find('Имя: '..pl_sob.nm) then
			if text:find('Полностью здоровый') then
				sob_info.hp = 0
			else
				sob_info.hp = 1
			end
			sob_info.narko = tonumber(text:match('Наркозависимость: ([%d%.]+)'))
			
			return false
		elseif title:find('Паспорт') and text:find('Имя: {FFD700}'..pl_sob.nm) then
			local black_list_org = {'Больница LS', 'Больница SF', 'Больница LV', 'Больница Jafferson', 'Центр лицензирования', 'Центральный Банк'} 
			local num_org = 1
			if setting.frac.org == u8'Больница СФ' then
				num_org = 2
			elseif setting.frac.org == u8'Больница ЛВ' then
				num_org = 3
			elseif setting.frac.org == u8'Больница Джефферсон' then
				num_org = 4
			elseif setting.frac.org == u8'Центр Лицензирования' then
				num_org = 5
			elseif setting.frac.org == u8'Центральный Банк' then
				num_org = 6
			end
			if text:find('Организация:') then
				sob_info.work = 1
			else
				sob_info.work = 0
			end
			if text:find('%{FF6200%} '..black_list_org[num_org]) then
				sob_info.bl = 1
			else
				sob_info.bl = 0
			end
			sob_info.level = tonumber(text:match('Лет в штате: %{FFD700%}(%d+)'))
			sob_info.legal = tonumber(text:match('Законопослушность: %{FFD700%}(%d+)'))
			
			return false
		end
	end
	if id == 235 then
		if text:find('Должность: {B83434}(.-)') then
			local text_org, rank_org = text:match('Должность: {B83434}(.-)%((%d+)%)')
			pers.frac.title = u8(text_org)
			pers.frac.rank = u8(rank_org)
			setting.frac.rank = u8(rank_org)
			setting.frac.title = u8(text_org)
			save('setting')
		end
		if close_stats then 
			close_stats = false
			return false
		end
	end
	if id == 713 and num_give_bank > -1 then
		sampSendDialogResponse(713, 1, num_give_bank, nil)
		num_give_bank = -1
		return false
	end
end

function EXPORTS.sendRequest()
	if not sampIsDialogActive() then
		members_wait.members = true
		sampSendChat('/members')
		return true
	end
	return false
end

function activate_function_members()
	while true do wait(0)
		if sampIsLocalPlayerSpawned() and not sampIsDialogActive() then
			while (os.clock() - lastDialogWasActive) < 2.00 do wait(0) end
			if not members_wait.members and setting.members.func and thread:status() == 'dead' and not sampIsDialogActive() then
				members_wait.members = true
				dont_show_me_members = false
				sampSendChat('/members')
			end
			wait(7500)
		end
	end
end

function onWindowMessage(msg, wparam, lparam)
	if wparam == 0x1B and not isPauseMenuActive() then
		if win.action_choice.v then
			consumeWindowMessage(true, false)
			win.action_choice.v = false
		end
		if win.main.v then
			consumeWindowMessage(true, false)
			interf.main.anim_win.par = true
		end
	end
end

function getAfkCount()
	local count = 0
	for _, v in ipairs(members) do
		if v.afk > 0 then
			count = count + 1
		end
	end
	return count
end

--> Сцена
function scene_work()
	if scene_active then
		setVirtualKeyDown(0x79, true)
		cam_hack()
	end
	local X, Y = scene_buf.pos.x, scene_buf.pos.y
	for i, sc in ipairs(scene_buf.qq) do
		local color = changeColorAlpha(sc.color, scene_buf.vis)
		local text_end = u8:decode(sc.text)
		
		if sc.type_color ~= u8'Свой текст и цвет' then
			if sc.type_color == u8'/me' then
				text_end = '{FF99FF}'..sc.nm..' '..u8:decode(sc.text)
			elseif sc.type_color == u8'/do' then
				text_end = '{4682b4}'..u8:decode(sc.text)..' | '..sc.nm
			elseif sc.type_color == u8'/todo' then
				text_end = '{FFFFFF}'..u8:decode(sc.text)..' - сказал(а) '..sc.nm..', {FF99FF}'..u8:decode(sc.act)
			elseif sc.type_color == u8'Речь' then
				text_end = '{FFFFFF}'..sc.nm..' говорит: '..u8:decode(sc.text)
			end
		end
		if scene_buf.invers then
			renderFontDrawClickableText(script_cursor_sc, font_sc, text_end, X, Y, color, color, 3, true)
		else
			renderFontDrawClickableText(script_cursor_sc, font_sc, text_end, X, Y, color, color, 4, true)
		end
		Y = Y + scene_buf.dist
	end
	if scene_active then
		if isKeyDown(0x01) or isKeyJustPressed(VK_ESCAPE) then
			setVirtualKeyDown(0x79, false)
			scene_active = false
			sampSetCursorMode(0)
			win.main.v = true
			imgui.ShowCursor = true
			displayRadar(true)
			displayHud(true)
			radarHud = 0
			angPlZ = angZ * -1.0
			lockPlayerControl(false)
			restoreCameraJumpcut()
			setCameraBehindPlayer()
		end
	end
end

function scene_edit()
	scene_edit_i = true
	setVirtualKeyDown(0x79, true)
	pos_sc = lua_thread.create(function()
		local backup = {
			['x'] = scene_buf.pos.x,
			['y'] = scene_buf.pos.y
		}
		local pos_sc_edit = true
		sampSetCursorMode(4)
		win.main.v = false
		if not sampIsChatInputActive() then
			while not sampIsChatInputActive() and pos_sc_edit do
				wait(0)
				local cX, cY = getCursorPos()
				scene_buf.pos.x = cX
				scene_buf.pos.y = cY
				if isKeyDown(0x01) then
					while isKeyDown(0x01) or isKeyDown(0x0D) do wait(0) end
					pos_sc_edit = false
				elseif isKeyJustPressed(VK_ESCAPE) then
					pos_sc_edit = false
					scene_buf.pos.x = backup['x']
					scene_buf.pos.y = backup['y']
				end
			end
		end
		sampSetCursorMode(0)
		setVirtualKeyDown(0x79, false)
		scene_edit_i = false
		win.main.v = true
		imgui.ShowCursor = true
		pos_sc_edit = false
	end)
end

--> Автоскрин
function print_scr()
	lua_thread.create(function()
		setVirtualKeyDown(VK_F8, true)
		wait(25)
		setVirtualKeyDown(VK_F8, false)
	end)
end

--> Автоскрин + /time
function print_scr_time()
	lua_thread.create(function()
		sampSendChat('/time')
		wait(1500)
		setVirtualKeyDown(VK_F8, true)
		wait(25)
		setVirtualKeyDown(VK_F8, false)
	end)
end

--> Акценты
sampRegisterChatCommand('r', function(text_accents_r) 
	if setting.teg ~= '' and setting.teg ~= ' ' and text_accents_r ~= '' and not setting.accent.func then
		sampSendChat('/r ['..u8:decode(setting.teg)..']: '..text_accents_r)
	elseif setting.teg == '' and text_accents_r ~= '' and setting.accent.func and setting.accent.r and setting.accent.text ~= '' then
		sampSendChat('/r ['..u8:decode(setting.accent.text)..' акцент]: '..text_accents_r)
	elseif setting.teg ~= '' and setting.teg ~= ' ' and text_accents_r ~= '' and setting.accent.func and setting.accent.r and setting.accent.text ~= '' then
		sampSendChat('/r ['..u8:decode(setting.teg)..']['..u8:decode(setting.accent.text)..' акцент]: '..text_accents_r)
	else
		sampSendChat('/r '..text_accents_r)
	end 
end)
sampRegisterChatCommand('s', function(text_accents_s) 
	if text_accents_s ~= '' and setting.accent.func and setting.accent.s and setting.accent.text ~= '' then
		sampSendChat('/s ['..u8:decode(setting.accent.text)..' акцент]: '..text_accents_s)
	else
		sampSendChat('/s '..text_accents_s)
	end 
end)
sampRegisterChatCommand('f', function(text_accents_f) 
	if text_accents_f ~= '' and setting.accent.func and setting.accent.f and setting.accent.text ~= '' then
		sampSendChat('/f ['..u8:decode(setting.accent.text)..' акцент]: '..text_accents_f)
	else
		sampSendChat('/f '..text_accents_f)
	end 
end)

function hook.onSendCommand(cmd)
	if cmd:find('/r ') then
		if setting.act_r ~= '' and setting.act_r ~= ' ' then
			lua_thread.create(function()
			wait(700)
			sampSendChat(u8:decode(setting.act_r))
			end)
		end
	end
	if cmd:find('/time') then
		if setting.act_time ~= '' and setting.act_time ~= ' ' then
			lua_thread.create(function()
			wait(700)
			sampSendChat(u8:decode(setting.act_time))
			end)
		end
	end
end

function hook.onSendChat(message)
    if setting.accent.func then
		if message == ')' or message == '(' or message ==  '))' or message == '((' or message == 'xD' or message == ':D' or message == ':d' or message == 'XD' or message == ':)' or message == ':(' then return {message} end
		
		if setting.accent.text ~= '' then
			return{'['..u8:decode(setting.accent.text)..' акцент]: '..message}
		end
    end
end

--> Тайм худ
local BuffSize = 32
local KeyboardLayoutName = ffi.new('char[?]', BuffSize)
local LocalInfo = ffi.new('char[?]', BuffSize)
local month = {'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня', 'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'}

function getStrByState(keyState)
	if keyState == 0 then
		return '{ffeeaa}Выкл{ffffff}'
	end
	return '{53E03D}Вкл{ffffff}'
end

function getStrByState2(keyState)
	if keyState == 0 then
		return ''
	end
	return '{F55353}Caps{ffffff}'
end

function time_hud_func()
	local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
	local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
	local localName = ffi.string(LocalInfo)
	local capsState = ffi.C.GetKeyState(20)
	local function lang()
		local str = string.match(localName, '([^%(]*)')
		if str:find('Русский') then
			return 'Ru'
		elseif str:find('Английский') then
			return 'En'
		end
	end
	local text = string.format('%s | {ffeeaa}%s{ffffff} %s', os.date('%d ')..month[tonumber(os.date('%m'))]..os.date(' - %H:%M:%S'), lang(), getStrByState2(capsState))
	renderFontDrawText(fontPD, text, 20, sy-25, 0xFFFFFFFF)
end

--> Прочие важные функции
function round(num, step) --> Число - шаг округления
  return math.ceil(num / step) * step
end

function chsex(text_man, text_woman)
	if setting.sex == u8'Мужской' then
		return text_man
	else
		return text_woman
	end
end

function urlencode(str)
   if (str) then
      str = string.gsub (str, '\n', '\r\n')
      str = string.gsub (str, '([^%w ])',
         function (c) return string.format ('%%%02X', string.byte(c)) end)
      str = string.gsub (str, ' ', '+')
   end
   return str
end

function asyncHttpRequest(method, url, args, resolve, reject)
	local request_thread = effil.thread(function (method, url, args)
		local requests = require 'requests'
		local result, response = pcall(requests.request, method, url, args)
		if result then
			response.json, response.xml = nil, nil
			return true, response
		else
			return false, response
		end
	end)(method, url, args)

	if not resolve then resolve = function() end end
	if not reject then reject = function() end end

	lua_thread.create(function()
		local runner = request_thread
		while true do
			local status, err = runner:status()
			if not err then
				if status == 'completed' then
					local result, response = runner:get()
					if result then
						resolve(response)
					else
						reject(response)
					end
					return
				elseif status == 'canceled' then
					return reject(status)
				end
			else
				return reject(err)
			end
			wait(0)
		end
	end)
end

convert_color = function(argb)
	local col = imgui.ColorConvertU32ToFloat4(argb)
	return imgui.ImFloat4(col.z, col.y, col.x, col.w)
end

function explode_U32(u32)
	local a = bit.band(bit.rshift(u32, 24), 0xFF)
	local r = bit.band(bit.rshift(u32, 16), 0xFF)
	local g = bit.band(bit.rshift(u32, 8), 0xFF)
	local b = bit.band(u32, 0xFF)
	return a, r, g, b
end

function join_argb(a, r, g, b)
	local argb = b
	argb = bit.bor(argb, bit.lshift(g, 8))
	argb = bit.bor(argb, bit.lshift(r, 16))
	argb = bit.bor(argb, bit.lshift(a, 24))
	return argb
end

function changeColorAlpha(argb, alpha)
	local _, r, g, b = explode_U32(argb)
	return join_argb(alpha, r, g, b)
end

function ARGBtoStringRGB(abgr)
	local a, r, g, b = explode_U32(abgr)
	local argb = join_argb(a, r, g, b)
	local color = ('%x'):format(bit.band(argb, 0xFFFFFF))
	return ('{%s%s}'):format(('0'):rep(6 - #color), color)
end

function imgui.ColorConvertFloat4ToARGB(float4)
	local abgr = imgui.ColorConvertFloat4ToU32(float4)
	local a, b, g, r = explode_U32(abgr)
	return join_argb(a, r, g, b)
end

function isCursorAvailable()
	return (not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen())
end

function renderFontDrawClickableText(active, font, text, posX, posY, color, color_hovered, align, b_symbol)
	local cursorX, cursorY = getCursorPos()
	local lenght = renderGetFontDrawTextLength(font, text)
	local height = renderGetFontDrawHeight(font)
	local symb_len = renderGetFontDrawTextLength(font, '>')
	local hovered = false
	local result = false
    b_symbol = b_symbol == nil and false or b_symbol
    align = align or 1

    if align == 2 then
    	posX = posX - (lenght / 2)
    elseif align == 3 then
    	posX = posX - lenght
	end

    if active and cursorX > posX and cursorY > posY and cursorX < posX + lenght and cursorY < posY + height then
        hovered = true
        if isKeyJustPressed(0x01) then
        	result = true 
        end
    end

    local anim = math.floor(math.sin(os.clock() * 10) * 3 + 5)
 	if hovered and b_symbol and (align == 2 or align == 1) then
    	renderFontDrawText(font, '>', posX - symb_len - anim, posY, 0x90FFFFFF)
    end 
    renderFontDrawText(font, text, posX, posY, hovered and color_hovered or color)
    if hovered and b_symbol and (align == 2 or align == 3) then
    	renderFontDrawText(font, '<', posX + lenght + anim, posY, 0x90FFFFFF)
    end 

    return result
end

function changePosition()
	if setting.members.func then
		pos_new_memb = lua_thread.create(function()
			local backup = {
				['x'] = setting.members.pos.x,
                ['y'] = setting.members.pos.y
			}
			local ChangePos = true
			sampSetCursorMode(4)
			win.main.v = false
			sampAddChatMessage(script_tag..'{FFFFFF}Нажмите {FF6060}ЛКМ{FFFFFF}, чтобы применить или {FF6060}ESC{FFFFFF} для отмены.', color_tag)
            if not sampIsChatInputActive() then
                while not sampIsChatInputActive() and ChangePos do
                    wait(0)
                    local cX, cY = getCursorPos()
                    setting.members.pos.x = cX
                    setting.members.pos.y = cY
                    if isKeyDown(0x01) then
                    	while isKeyDown(0x01) do wait(0) end
                        ChangePos = false
						save('setting')
                        sampAddChatMessage(script_tag..'{FFFFFF}Позиция сохранена.', color_tag)
                    elseif isKeyJustPressed(VK_ESCAPE) then
                        ChangePos = false
						setting.members.pos.x = backup['x']
						setting.members.pos.y = backup['y']
                        sampAddChatMessage(script_tag..'{FFFFFF}Вы отменили изменение позиции.', color_tag)
                    end
                end
            end
            sampSetCursorMode(0)
            win.main.v = true
			imgui.ShowCursor = true
            ChangePos = false
		end)
	end
end

function render_members()
	local X, Y = setting.members.pos.x, setting.members.pos.y
	local title = string.format('%s | Онлайн: %s%s', org.name, org.online, (setting.members.afk and (' (%s в АФК)'):format(org.afk) or ''))
	local col_title = changeColorAlpha(setting.members.color.title, setting.members.vis)
	if setting.members.invers then
		if renderFontDrawClickableText(script_cursor, fontes, title, X, Y - setting.members.dist - 5, col_title, col_title, 4, false) then
			sampSendChat('/members')
		end
	else
		if renderFontDrawClickableText(script_cursor, fontes, title, X, Y - setting.members.dist - 5, col_title, col_title, 3, false) then
			sampSendChat('/members')
		end
	end
	if org.name == 'Гражданин' then
		if setting.members.invers then
			renderFontDrawClickableText(script_cursor, fontes, 'Вы не состоите в организации', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  4, false)
		else
			renderFontDrawClickableText(script_cursor, fontes, 'Вы не состоите в организации', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  3, false)
		end
	elseif #members > 0 then
		for i, member in ipairs(members) do
			if i <= tonumber(org.online) then
				local color = changeColorAlpha(setting.members.form and (member.uniform and setting.members.color.work or setting.members.color.default) or setting.members.color.default, setting.members.vis)
				local rank = setting.members.rank and string.format('[%s]', member.rank.count) or nil
				local nick = member.nick .. (setting.members.id and string.format('(%s)', member.id) or '')
				local afk = setting.members.afk and string.format(' (AFK: %s)', member.afk) or ''
				local warns = setting.members.warn and string.format(' (Warns: %s)', member.warns) or ''
				local out_string
				if setting.members.invers then
					out_string = ('%s%s%s%s'):format(rank and rank .. ' ' or '', nick, afk, warns)
					renderFontDrawClickableText(script_cursor, fontes, out_string, X, Y, color, color, 4, true)
				else
					out_string = ('%s%s%s%s'):format(rank and rank .. ' ' or '', nick, afk, warns)
					renderFontDrawClickableText(script_cursor, fontes, out_string, X, Y, color, color, 3, true)
				end
				Y = Y + setting.members.dist
			end
		end
	else
		if setting.members.invers then
			renderFontDrawClickableText(script_cursor, fontes, 'Ни один игрок не найден', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  4, false)
		else
			renderFontDrawClickableText(script_cursor, fontes, 'Ни один игрок не найден', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  3, false)
		end
	end
end

function on_hot_key(id_pr_key)
	local pressed_key = tostring(table.concat(id_pr_key, ' '))
	if pressed_key == '72' and setting.speed_door then
		sampSendChat('/opengate')
	end
	if thread:status() == 'dead' and not edit_key and #setting.cmd ~= 0 and not sampIsChatInputActive() and not sampIsDialogActive() then
		for k, v in pairs(setting.cmd) do
			if pressed_key == tostring(table.concat(v[3], ' ')) then
				cmd_start('', v[1])
				break
			end
		end
	end
end

function imgui.TextColoredRGB(string, max_float)

	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local u8 = require 'encoding'.UTF8

	local function color_imvec4(color)
		if color:upper():sub(1, 6) == 'SSSSSS' then return imgui.ImVec4(colors[clr.Text].x, colors[clr.Text].y, colors[clr.Text].z, tonumber(color:sub(7, 8), 16) and tonumber(color:sub(7, 8), 16)/255 or colors[clr.Text].w) end
		local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
		local rgb = {}
		for i = 1, #color/2 do rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16) end
		return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
	end

	local function render_text(string)
		for w in string:gmatch('[^\r\n]+') do
			local text, color = {}, {}
			local render_text = 1
			local m = 1
			if w:sub(1, 8) == '[center]' then
				render_text = 2
				w = w:sub(9)
			elseif w:sub(1, 7) == '[right]' then
				render_text = 3
				w = w:sub(8)
			end
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				if tonumber(w:sub(n+1, k-1), 16) or (w:sub(n+1, k-3):upper() == 'SSSSSS' and tonumber(w:sub(k-2, k-1), 16) or w:sub(k-2, k-1):upper() == 'SS') then
					text[#text], text[#text+1] = w:sub(m, n-1), w:sub(k+1, #w)
					color[#color+1] = color_imvec4(w:sub(n+1, k-1))
					w = w:sub(1, n-1)..w:sub(k+1, #w)
					m = n
				else w = w:sub(1, n-1)..w:sub(n, k-3)..'}'..w:sub(k+1, #w) end
			end
			local length = imgui.CalcTextSize(u8(w))
			if render_text == 2 then
				imgui.NewLine()
				imgui.SameLine(max_float / 2 - ( length.x / 2 ))
			elseif render_text == 3 then
				imgui.NewLine()
				imgui.SameLine(max_float - length.x - 5 )
			end
			if text[0] then
				for i, k in pairs(text) do
					imgui.TextColored(color[i] or colors[clr.Text], u8(k))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(u8(w)) end
		end
	end
	render_text(string)
end

function time()
	local function get_weekday(year, month, day)
		local weekday = tonumber(os.date('%w', os.time{year = year, month = month, day = day}))
		if weekday == 0 then
			weekday = 7
		end

		return weekday
	end
	
	while true do
		wait(1000)
		if sampGetGamestate() == 3 then
			if #setting.reminder ~= 0 then
				local current_date_all = os.date('*t')
				local current_date = {
					year = tonumber(current_date_all.year),
					mon	= tonumber(current_date_all.month),
					day = tonumber(current_date_all.day),
					hour = tonumber(current_date_all.hour),
					min = tonumber(current_date_all.min),
				}
				for i = 1, #setting.reminder do
					local repeat_true = false
					local cur_day_rep = false
					for m = 1, #setting.reminder[i].repeats do
						if setting.reminder[i].repeats[m] then repeat_true = true break end
					end
					if setting.reminder[i].year == current_date.year and setting.reminder[i].mon == current_date.mon and
					setting.reminder[i].day == current_date.day and setting.reminder[i].hour == current_date.hour and
					setting.reminder[i].min == current_date.min then
						cur_day_rep = true
						if not setting.reminder[i].execution then
							win.reminder.v = true
							imgui.ShowCursor = true
							if setting.reminder[i].sound then
								lua_thread.create(function()
									local stop_signal = 0
									repeat wait(200) 
										addOneOffSound(0, 0, 0, 1057)
										stop_signal = stop_signal + 1
									until stop_signal > 17
								end)
							end
							rem_text = setting.reminder[i].nm
							setting.reminder[i].execution = true
							save('setting')
						end
					elseif setting.reminder[i].hour ~= current_date.hour and setting.reminder[i].min ~= current_date.min then
						setting.reminder[i].execution = false
						save('setting')
					end
					if not cur_day_rep and repeat_true and not setting.reminder[i].execution and setting.reminder[i].hour == current_date.hour and setting.reminder[i].min == current_date.min then
						local week_day = get_weekday(current_date.year, current_date.mon, current_date.day)
						if setting.reminder[i].repeats[week_day] then
							win.reminder.v = true
							imgui.ShowCursor = true
							if setting.reminder[i].sound then
								lua_thread.create(function()
									local stop_signal = 0
									repeat wait(200) 
										addOneOffSound(0, 0, 0, 1057)
										stop_signal = stop_signal + 1
									until stop_signal > 17
								end)
							end
							rem_text = setting.reminder[i].nm
							setting.reminder[i].execution = true
							save('setting')
						end
					end
				end
			end
			
			if not isGamePaused() then
				session_clean.v = session_clean.v + 1
				session_all.v = session_all.v + 1
			
				setting.online_stat.clean[1] = setting.online_stat.clean[1] + 1
				setting.online_stat.all[1] = setting.online_stat.all[1] + 1
				setting.online_stat.total_all = setting.online_stat.total_all + 1
			else
				session_all.v = session_all.v + 1
				session_afk.v = session_afk.v + 1
				
				setting.online_stat.all[1] = setting.online_stat.all[1] + 1
				setting.online_stat.afk[1] = setting.online_stat.afk[1] + 1
			end
		end
		
		if get_status_potok_song() == 1 and track_time_hc ~= 0 then
			local time_song = 0
			time_song = time_song_position(track_time_hc)
			time_song = round(time_song, 1)
			timetr[1] = time_song % 60
			timetr[2] = math.floor(time_song / 60)
		end
		
		if close_stats then
			sampSendChat('/stats')
		end
	end
end

function save_coun_onl()
	while true do 
		wait(60000)
		save('setting')
	end
end

--> Кам-Хак
function cam_hack()
	if not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
		offMouX, offMouY = getPcMouseMovement()
		angZ = (angZ + offMouX/4.0) % 360.0
		angY = math.min(89.0, math.max(-89.0, angY + offMouY/4.0))
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)
		curZ = angZ + 180.0
		curY = angY * -1.0
		radZ = math.rad(curZ)
		radY = math.rad(curY)
		sinZ = math.sin(radZ)
		cosZ = math.cos(radZ)
		sinY = math.sin(radY)
		cosY = math.cos(radY)
		sinZ = sinZ * cosY
		cosZ = cosZ * cosY
		sinZ = sinZ * 10.0
		cosZ = cosZ * 10.0
		sinY = sinY * 10.0
		posPlX = posX + sinZ
		posPlY = posY + cosZ
		posPlZ = posZ + sinY
		angPlZ = angZ * -1.0
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_W) then
			radZ = math.rad(angZ)
			radY = math.rad(angY)
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)
			sinY = math.sin(radY)
			cosY = math.cos(radY)
			sinZ = sinZ * cosY
			cosZ = cosZ * cosY
			sinZ = sinZ * speed
			cosZ = cosZ * speed
			sinY = sinY * speed
			posX = posX + sinZ
			posY = posY + cosZ
			posZ = posZ + sinY
			setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
		end
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_S) then
			curZ = angZ + 180.0
			curY = angY * -1.0
			radZ = math.rad(curZ)
			radY = math.rad(curY)
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)
			sinY = math.sin(radY)
			cosY = math.cos(radY)
			sinZ = sinZ * cosY
			cosZ = cosZ * cosY
			sinZ = sinZ * speed
			cosZ = cosZ * speed
			sinY = sinY * speed
			posX = posX + sinZ
			posY = posY + cosZ
			posZ = posZ + sinY
			setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
		end
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_A) then
			curZ = angZ - 90.0
			radZ = math.rad(curZ)
			radY = math.rad(angY)
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)
			sinZ = sinZ * speed
			cosZ = cosZ * speed
			posX = posX + sinZ
			posY = posY + cosZ
			setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
		end
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_D) then
			curZ = angZ + 90.0
			radZ = math.rad(curZ)
			radY = math.rad(angY)
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)
			sinZ = sinZ * speed
			cosZ = cosZ * speed
			posX = posX + sinZ
			posY = posY + cosZ
			setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
		end
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_SHIFT) then
			posZ = posZ + speed
			setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
		end
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_CONTROL) then
			posZ = posZ - speed
			setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
		end
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_F10) then
			displayRadar(false)
			displayHud(false)
		else
			displayRadar(true)
			displayHud(true)
		end
	end
end

function hook.onSendAimSync()
    if camhack_active then
		return false
    end
end

function onScriptTerminate(script, quit)
	if script == thisScript() and not quit and camhack_active then
		displayRadar(true)
		displayHud(true)
		lockPlayerControl(false)
		restoreCameraJumpcut()
		setCameraBehindPlayer()
	end
end

local onday = false
function print_time(time)
	local timehighlight = 86400 - os.date('%H', 0) * 3600
	if tonumber(time) >= 86400 then onDay = true else onDay = false end
	return os.date((onDay and math.floor(time / 86400)..' д. ' or '')..('%H ч. %M мин.'), time + timehighlight)
end
