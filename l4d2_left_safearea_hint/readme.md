# 玩家离开安全区域后提示信息



玩家离开开始安全区域后提示信息。

可在配置文件中配置提示类型：

> l4d2_left_safearea_hint.cfg

```
// 显示多少条提示信息（请根据translations/l4d2_left_safearea_hint.phrases.txt文件中配置的条目数量来设定具体值）.
// -
// Default: "3"
l4d2_left_safearea_hint_count "3"

// 以哪种方式输出提示信息（可相加组合）.
// 1 = 聊天框提示信息.
// 2 = 屏幕中下提示信息.
// 4 = 屏幕中上提示信息.
// 可相加组合（例：配置为3，则既以聊天框形式输出提示信息，也以屏幕中下文字形式输出提示信息）.
// -
// Default: "2"
l4d2_left_safearea_hint_type "2"
```



默认翻译配置文件定义如下：

> l4d2_left_safearea_hint.phrases.txt

```
"Phrases"
{
	"Msg1"
	{
		"en"		"This server is PUBLIC, please don't use it as a private room."
		"chi"		"此服务器为公共服务器，请不要当作私人房间使用。"
		"zho"		"此伺服器為公共伺服器，請不要當作私人房間使用。"
		"jp"		"このサーバはパブリックサーバです。プライベートルームとしては使用しないでください。"
		"ko"		"이 서버는 공용 서버이므로 개인실로 사용하지 마십시오."
	}
	"Msg2"
	{
		"en"		"Even if you chose 'Friends Only' or 'Private', other players can still join this server."
		"chi"		"即使您选择的是 “仅限好友” 或 “私人游戏” ，其他玩家仍能加入此服务器。"
		"zho"		"即使您選擇的是 “僅限好友” 或 “私人游戲” ，其他玩家仍能加入此伺服器。"
		"jp"		"「友達限定」や「プライベートゲーム」を選択した場合でも、他のプレイヤーはこのサーバーに参加することができます。"
		"ko"		"'친구만' 또는 '개인 게임' 을 선택하더라도 다른 플레이어가 이 서버에 가입할 수 있습니다."
	}
	"Msg3"
	{
		"en"		"Please don't vote kick other players. Thank you!"
		"chi"		"请勿随意踢出其他玩家。谢谢！"
		"zho"		"請勿隨意踢出其他玩家。謝謝！"
		"jp"		"他のプレイヤーを勝手に蹴り出さないでください。 ありがとうございます！"
		"ko"		"다른 게이머를 마음대로 쫓아내지 마세요. 감사합니다!"
	}
}
```



您可自定义输出的提示信息，注意每条信息命名必须以 "Msg+数字" 的方式命名，且每条信息必须有 "en" 英语标签才可正常输出。

例：

```
"Phrases"
{
	......

	"Msg4"
	{
		"en"		"Meow~"
		"chi"		"喵~"
		"zho"		"喵~"
	}
}
```

