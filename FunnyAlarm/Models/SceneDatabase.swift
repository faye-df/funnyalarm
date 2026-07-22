import Foundation

/// MVP 18 个内置随机场景数据库 (每类 6 个)
public struct SceneDatabase {
    public static let allScenes: [ScenePack] = [
        // MARK: - A. 6 个自拍姿势场景 (Pose)
        ScenePack(
            id: "pose_heart",
            name: "晨光比心",
            icon: "🫶",
            type: .pose,
            promptTitle: "对着前摄做双手比心姿势",
            promptDetail: "保持可爱微笑与比心 1.5 秒完成唤醒",
            keywordsOrTarget: ["heart"],
            defaultRingtoneName: "cheerful_morning",
            themeHex: "FFD9D2"
        ),
        ScenePack(
            id: "pose_stretch",
            name: "高举双臂伸懒腰",
            icon: "🙆‍♂️",
            type: .pose,
            promptTitle: "将双手高举过头顶",
            promptDetail: "把睡意全部释放出去！",
            keywordsOrTarget: ["raise_hands"],
            defaultRingtoneName: "sunrise_gong",
            themeHex: "9FE3C2"
        ),
        ScenePack(
            id: "pose_tilt_smile",
            name: "歪头元气笑",
            icon: "😜",
            type: .pose,
            promptTitle: "向左或右歪头 20 度并露出笑容",
            promptDetail: "启动今日的阳光心情",
            keywordsOrTarget: ["head_tilt"],
            defaultRingtoneName: "pop_up",
            themeHex: "FFE46B"
        ),
        ScenePack(
            id: "pose_face_hold",
            name: "双手托脸防肿",
            icon: "🖐️",
            type: .pose,
            promptTitle: "用双手轻捧双颊",
            promptDetail: "消水肿第一步！保持 1.5 秒",
            keywordsOrTarget: ["hold_face"],
            defaultRingtoneName: "marimba_wave",
            themeHex: "6ECDF2"
        ),
        ScenePack(
            id: "pose_salute",
            name: "宇宙长官报到",
            icon: "🫡",
            type: .pose,
            promptTitle: "做出标准敬礼姿势",
            promptDetail: "长官，今日任务已就绪！",
            keywordsOrTarget: ["salute"],
            defaultRingtoneName: "brass_fanfare",
            themeHex: "FFF1F4"
        ),
        ScenePack(
            id: "pose_wink",
            name: "单眼眨眼绝杀",
            icon: "😉",
            type: .pose,
            promptTitle: "对着镜头单眼眨眼",
            promptDetail: "自信满满开启新的一天",
            keywordsOrTarget: ["wink"],
            defaultRingtoneName: "sparkle_chime",
            themeHex: "FF7F6E"
        ),

        // MARK: - B. 6 个语音互动场景 (Voice)
        ScenePack(
            id: "voice_chancellor",
            name: "财政大臣印钞",
            icon: "💼",
            type: .voice,
            promptTitle: "大声念出印钞指令",
            promptDetail: "“One million, two million, print the money!”",
            keywordsOrTarget: ["million", "money", "print", "one", "two"],
            defaultRingtoneName: "cash_register",
            themeHex: "FFE46B"
        ),
        ScenePack(
            id: "voice_agent",
            name: "零零柒低语",
            icon: "🕶️",
            type: .voice,
            promptTitle: "低沉念出特工密令",
            promptDetail: "“Mission accomplished, copy that!”",
            keywordsOrTarget: ["mission", "copy", "accomplished", "delta"],
            defaultRingtoneName: "radar_ping",
            themeHex: "656565"
        ),
        ScenePack(
            id: "voice_zen",
            name: "禅宗晨音",
            icon: "🧘",
            type: .voice,
            promptTitle: "深呼吸发出共鸣嗡音",
            promptDetail: "“Peace is within, my mind is clear.”",
            keywordsOrTarget: ["peace", "mind", "clear", "within", "om"],
            defaultRingtoneName: "temple_singing_bowl",
            themeHex: "9FE3C2"
        ),
        ScenePack(
            id: "voice_overboss",
            name: "霸总买下大盘",
            icon: "💵",
            type: .voice,
            promptTitle: "霸气喊出收购指令",
            promptDetail: "“Buy the company, double the price!”",
            keywordsOrTarget: ["buy", "company", "double", "price"],
            defaultRingtoneName: "stock_ring",
            themeHex: "FF7F6E"
        ),
        ScenePack(
            id: "voice_earth_hello",
            name: "地球广播站",
            icon: "🌍",
            type: .voice,
            promptTitle: "对全宇宙大声早安",
            promptDetail: "“Good morning Earth, I am awake!”",
            keywordsOrTarget: ["good", "morning", "earth", "awake"],
            defaultRingtoneName: "cosmic_synth",
            themeHex: "6ECDF2"
        ),
        ScenePack(
            id: "voice_hero_roar",
            name: "英雄狮吼",
            icon: "🦁",
            type: .voice,
            promptTitle: "对着麦克风长叹气或吼一声",
            promptDetail: "“吼—— 能量满满！”",
            keywordsOrTarget: ["roar", "能量", "满满", "吼"],
            defaultRingtoneName: "tribal_drums",
            themeHex: "FFD9D2"
        ),

        // MARK: - C. 6 个迷你游戏场景 (Mini-Game)
        ScenePack(
            id: "game_color_sequence",
            name: "幸运色盘点阵",
            icon: "🎨",
            type: .miniGame,
            promptTitle: "记住并复述 4 色顺序",
            promptDetail: "点击对应颜色点阵解锁闹钟",
            keywordsOrTarget: ["color_sequence"],
            defaultRingtoneName: "arcade_8bit",
            themeHex: "6ECDF2"
        ),
        ScenePack(
            id: "game_rhythm_tap",
            name: "晨间节拍跟弹",
            icon: "🎵",
            type: .miniGame,
            promptTitle: "跟随节奏轻点 5 次圆圈",
            promptDetail: "激活神经元连通",
            keywordsOrTarget: ["rhythm_tap"],
            defaultRingtoneName: "synth_beat",
            themeHex: "FFE46B"
        ),
        ScenePack(
            id: "game_quick_sort",
            name: "清晨果冻分类",
            icon: "🧹",
            type: .miniGame,
            promptTitle: "快速左右滑动消除 6 个果冻",
            promptDetail: "把瞌睡垃圾统统扫走！",
            keywordsOrTarget: ["quick_sort"],
            defaultRingtoneName: "bouncy_jelly",
            themeHex: "9FE3C2"
        ),
        ScenePack(
            id: "game_path_trace",
            name: "迷宫穿梭笔触",
            icon: "✏️",
            type: .miniGame,
            promptTitle: "单手一笔划过安全路径",
            promptDetail: "手眼协调唤醒专注力",
            keywordsOrTarget: ["path_trace"],
            defaultRingtoneName: "smooth_whistle",
            themeHex: "FFD9D2"
        ),
        ScenePack(
            id: "game_bubble_pop",
            name: "噩梦气泡捏捏乐",
            icon: "🧼",
            type: .miniGame,
            promptTitle: "连续戳破 8 个浮动气泡",
            promptDetail: "啪啪啪！消灭所有赖床气",
            keywordsOrTarget: ["bubble_pop"],
            defaultRingtoneName: "pop_pop",
            themeHex: "FFF1F4"
        ),
        ScenePack(
            id: "game_card_match",
            name: "晨间记忆卡牌",
            icon: "🃏",
            type: .miniGame,
            promptTitle: "找出 2 对相同的可爱卡牌",
            promptDetail: "激活工作记忆大脑",
            keywordsOrTarget: ["card_match"],
            defaultRingtoneName: "card_flip",
            themeHex: "FF7F6E"
        )
    ]

    /// 根据 ID 查找场景
    public static func find(by id: String) -> ScenePack {
        allScenes.first(where: { $0.id == id }) ?? allScenes[0]
    }
}
