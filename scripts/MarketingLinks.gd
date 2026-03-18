extends Node
## Autoload providing canonical book URLs and cross-platform browser open.

const BOOK1_URL := "https://www.amazon.com/dp/B0DNGQ3PKN"
const BOOK3_URL := "https://www.amazon.com/dp/B0F1JY3GLP"
const FREE_STORY_URL := "https://www.medias-novels.com/free-story"
const SERIES_URL := "https://www.medias-novels.com"


func open(url: String) -> void:
	if OS.has_feature("web"):
		var safe_url := url.replace("\\", "\\\\").replace("'", "\\'")
		JavaScriptBridge.eval("window.open('%s', '_blank')" % safe_url)
	else:
		OS.shell_open(url)
