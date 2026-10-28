import '../models/story.dart';

Map<String, Story> getStories() {
  return {
    'zhouyi': _zhouyiStory(),
    'lunyu': _lunyuStory(),
    'shijing': _shijingStory(),
    'shangshu': _shangshuStory(),
    'zhouli': _zhouliStory(),
    'xiaojing': _xiaojingStory(),
  };
}

Story _zhouyiStory() {
  return Story(
    characterId: 'zhouyi',
    title: '观复山之遇',
    description: '登临观复山，遇见迷雾中的智者',
    startNodeId: 'start',
    nodes: {
      'start': StoryNode(
        id: 'start',
        speaker: '旁白',
        text: '你沿着蜿蜒的石阶登上观复山。山顶云雾缭绕，隐约可见一道身影立于崖边，白衣胜雪，背对着你。',
        choices: [
          StoryChoice(text: '上前恭敬行礼', affinityChange: 5, nextNodeId: 'greet_polite'),
          StoryChoice(text: '直接开口询问', affinityChange: 0, nextNodeId: 'greet_direct'),
        ],
      ),
      'greet_polite': StoryNode(
        id: 'greet_polite',
        speaker: '周易',
        expression: 'normal',
        text: '……来者止步。你寻我，所为何事？',
        choices: [
          StoryChoice(text: '想请教人生困惑', affinityChange: 5, nextNodeId: 'ask_life'),
          StoryChoice(text: '想学习易理智慧', affinityChange: 10, nextNodeId: 'ask_yi'),
        ],
      ),
      'greet_direct': StoryNode(
        id: 'greet_direct',
        speaker: '周易',
        expression: 'thinking',
        text: '嗯？倒是直爽。你既寻我，想必心中有疑。',
        choices: [
          StoryChoice(text: '确实有困惑想请教', affinityChange: 3, nextNodeId: 'ask_life'),
          StoryChoice(text: '好奇山上有什么', affinityChange: 0, nextNodeId: 'ask_mountain'),
        ],
      ),
      'ask_life': StoryNode(
        id: 'ask_life',
        speaker: '周易',
        expression: 'normal',
        text: '人生困惑，人皆有之。你看这山间云雾——看似迷茫，风一吹便散了。',
        choices: [
          StoryChoice(text: '那风何时来？', affinityChange: 5, nextNodeId: 'ask_wind'),
          StoryChoice(text: '我懂了，顺其自然', affinityChange: 8, nextNodeId: 'understand_flow'),
        ],
      ),
      'ask_yi': StoryNode(
        id: 'ask_yi',
        speaker: '周易',
        expression: 'smile',
        text: '学易？难得。易者，变也。天下万事，皆在变化之中。',
        choices: [
          StoryChoice(text: '请先生教我', affinityChange: 10, nextNodeId: 'teach_yi'),
          StoryChoice(text: '变中可有不变？', affinityChange: 8, nextNodeId: 'ask_constant'),
        ],
      ),
      'ask_mountain': StoryNode(
        id: 'ask_mountain',
        speaker: '周易',
        expression: 'normal',
        text: '山上有什么？有云，有风，有八层境界。你若有心，可自行探寻。',
        choices: [
          StoryChoice(text: '那我便去探一探', affinityChange: 5, nextNodeId: 'explore_mountain'),
          StoryChoice(text: '算了，先与先生聊聊', affinityChange: 3, nextNodeId: 'ask_life'),
        ],
      ),
      'ask_wind': StoryNode(
        id: 'ask_wind',
        speaker: '周易',
        expression: 'smile',
        text: '风何时来？你若等风，风未必来。你若前行，自有清风相随。',
        choices: [
          StoryChoice(text: '多谢先生指点', affinityChange: 5, nextNodeId: 'good_ending'),
        ],
      ),
      'understand_flow': StoryNode(
        id: 'understand_flow',
        speaker: '周易',
        expression: 'smile',
        text: '顺其自然，说得轻巧。顺，不是躺平；然，不是认命。是看清规律后的从容。',
        choices: [
          StoryChoice(text: '受教了', affinityChange: 5, nextNodeId: 'good_ending'),
        ],
      ),
      'teach_yi': StoryNode(
        id: 'teach_yi',
        speaker: '周易',
        expression: 'normal',
        text: '学易先学三：一曰变，二曰简，三曰不易。懂此三者，便入了门。',
        choices: [
          StoryChoice(text: '何为变、简、不易？', affinityChange: 5, nextNodeId: 'explain_three'),
        ],
      ),
      'ask_constant': StoryNode(
        id: 'ask_constant',
        speaker: '周易',
        expression: 'smile',
        text: '好问题！变中自有不变。四时更替是变，寒来暑往是不变。万物流转是变，生生不息是不变。',
        choices: [
          StoryChoice(text: '原来如此', affinityChange: 5, nextNodeId: 'good_ending'),
        ],
      ),
      'explain_three': StoryNode(
        id: 'explain_three',
        speaker: '周易',
        expression: 'normal',
        text: '变者，万事万物皆在变化；简者，大道至简，其理不繁；不易者，万变之中有其根本。',
        choices: [
          StoryChoice(text: '先生说得是', affinityChange: 3, nextNodeId: 'good_ending'),
        ],
      ),
      'explore_mountain': StoryNode(
        id: 'explore_mountain',
        speaker: '周易',
        expression: 'thinking',
        text: '有探索之心，便有收获。去吧，观复山八层，每一层都有不同的风景。',
        choices: [
          StoryChoice(text: '好！', affinityChange: 3, nextNodeId: 'normal_ending'),
        ],
      ),
      'good_ending': StoryNode(
        id: 'good_ending',
        speaker: '旁白',
        text: '你与周易在观复山上相谈甚欢。云雾渐散，阳光洒落，你心中的困惑似乎也清明了许多。这，便是易的智慧——在变化中寻得从容。',
        isEnding: true,
        endingType: 'good',
      ),
      'normal_ending': StoryNode(
        id: 'normal_ending',
        speaker: '旁白',
        text: '你开始探索观复山的八层秘境。周易的身影在云雾中若隐若现，似乎在等待你更深的领悟。这只是开始……',
        isEnding: true,
        endingType: 'normal',
      ),
    },
  );
}

Story _lunyuStory() {
  return Story(
    characterId: 'lunyu',
    title: '学城问道',
    description: '走进空寂的学城，遇见那位循循善诱的先生',
    startNodeId: 'start',
    nodes: {
      'start': StoryNode(
        id: 'start',
        speaker: '旁白',
        text: '你来到传说中的学城，却发现城中空无一人。正疑惑间，一位温厚的长者从巷中走来，手中握着一卷竹简。',
        choices: [
          StoryChoice(text: '拱手行礼问好', affinityChange: 10, nextNodeId: 'greet_polite'),
          StoryChoice(text: '好奇地询问', affinityChange: 5, nextNodeId: 'greet_curious'),
        ],
      ),
      'greet_polite': StoryNode(
        id: 'greet_polite',
        speaker: '论语',
        expression: 'smile',
        text: '呵呵，好一位知礼的年轻人。你来学城，是想学些什么？',
        choices: [
          StoryChoice(text: '想学为人处世之道', affinityChange: 8, nextNodeId: 'ask_way'),
          StoryChoice(text: '想学做学问的方法', affinityChange: 10, nextNodeId: 'ask_learn'),
        ],
      ),
      'greet_curious': StoryNode(
        id: 'greet_curious',
        speaker: '论语',
        expression: 'normal',
        text: '学城？呵呵，这城里的人啊，都去"习"了。学是知道，习是做到。',
        choices: [
          StoryChoice(text: '学和习不一样吗？', affinityChange: 5, nextNodeId: 'ask_xi'),
          StoryChoice(text: '那我也想去"习"', affinityChange: 8, nextNodeId: 'want_xi'),
        ],
      ),
      'ask_way': StoryNode(
        id: 'ask_way',
        speaker: '论语',
        expression: 'normal',
        text: '为人处世之道，说难也难，说简单也简单。不外乎"己所不欲，勿施于人"八个字。',
        choices: [
          StoryChoice(text: '就这么简单？', affinityChange: 3, nextNodeId: 'simple_way'),
          StoryChoice(text: '请先生详解', affinityChange: 8, nextNodeId: 'explain_way'),
        ],
      ),
      'ask_learn': StoryNode(
        id: 'ask_learn',
        speaker: '论语',
        expression: 'smile',
        text: '做学问？首先要"学而时习之"——学了之后，要时常去实践、去体会。',
        choices: [
          StoryChoice(text: '"习"是温习的意思吗？', affinityChange: 5, nextNodeId: 'ask_xi_meaning'),
          StoryChoice(text: '我明白了', affinityChange: 5, nextNodeId: 'understand_learn'),
        ],
      ),
      'ask_xi': StoryNode(
        id: 'ask_xi',
        speaker: '论语',
        expression: 'smile',
        text: '不一样。学是知道，习是做到。学是往脑子里装，习是往心里去、往身上落。',
        choices: [
          StoryChoice(text: '那如何才能"习"？', affinityChange: 8, nextNodeId: 'how_xi'),
        ],
      ),
      'want_xi': StoryNode(
        id: 'want_xi',
        speaker: '论语',
        expression: 'smile',
        text: '好啊！那我先问你一个问题——你觉得，"学而时习之，不亦说乎"的"说"，是什么意思？',
        choices: [
          StoryChoice(text: '是喜悦的悦', affinityChange: 5, nextNodeId: 'answer_yue'),
          StoryChoice(text: '是说话的说', affinityChange: 0, nextNodeId: 'answer_shuo'),
        ],
      ),
      'simple_way': StoryNode(
        id: 'simple_way',
        speaker: '论语',
        expression: 'smile',
        text: '大道至简。但简单不等于容易。知道是一回事，做到是另一回事。能终身行之，才算真懂。',
        choices: [
          StoryChoice(text: '先生说得对', affinityChange: 5, nextNodeId: 'good_ending'),
        ],
      ),
      'explain_way': StoryNode(
        id: 'explain_way',
        speaker: '论语',
        expression: 'normal',
        text: '详解？其实就一个字——"恕"。宽恕的恕，如心的恕。站在别人的角度想问题，就是仁了。',
        choices: [
          StoryChoice(text: '原来是这样', affinityChange: 5, nextNodeId: 'good_ending'),
        ],
      ),
      'ask_xi_meaning': StoryNode(
        id: 'ask_xi_meaning',
        speaker: '论语',
        expression: 'smile',
        text: '有人说是温习，有人说是实习。我说啊，"习"是小鸟学飞——反复地、笨拙地、一次次地尝试。',
        choices: [
          StoryChoice(text: '这个比喻真好', affinityChange: 8, nextNodeId: 'good_ending'),
        ],
      ),
      'understand_learn': StoryNode(
        id: 'understand_learn',
        speaker: '论语',
        expression: 'normal',
        text: '明白就好。学不是目的，习才是。把学到的道理，真正用到生活中去。',
        choices: [
          StoryChoice(text: '我记住了', affinityChange: 5, nextNodeId: 'good_ending'),
        ],
      ),
      'how_xi': StoryNode(
        id: 'how_xi',
        speaker: '论语',
        expression: 'normal',
        text: '从小事做起。比如"吾日三省吾身"——每天睡前想想，今天说的话做的事，有没有不妥的。',
        choices: [
          StoryChoice(text: '我试试', affinityChange: 5, nextNodeId: 'good_ending'),
        ],
      ),
      'answer_yue': StoryNode(
        id: 'answer_yue',
        speaker: '论语',
        expression: 'smile',
        text: '呵呵，多数人都这么说。但你有没有想过——为什么是喜悦？因为学到的东西能用出来，那种成就感，才是真的快乐。',
        choices: [
          StoryChoice(text: '有道理！', affinityChange: 5, nextNodeId: 'good_ending'),
        ],
      ),
      'answer_shuo': StoryNode(
        id: 'answer_shuo',
        speaker: '论语',
        expression: 'thinking',
        text: '说话？也不算错。学了之后，能说出来、与人讨论，也是一种收获。但更深的，是做到后的喜悦。',
        choices: [
          StoryChoice(text: '原来如此', affinityChange: 3, nextNodeId: 'normal_ending'),
        ],
      ),
      'good_ending': StoryNode(
        id: 'good_ending',
        speaker: '旁白',
        text: '你与论语先生在学城中边走边聊。阳光穿过古老的街巷，照在竹简上，也照进了你心里。这便是学的意义——不是塞满知识，而是点亮心灯。',
        isEnding: true,
        endingType: 'good',
      ),
      'normal_ending': StoryNode(
        id: 'normal_ending',
        speaker: '旁白',
        text: '学城的钟声悠悠响起。论语先生微笑着看着你，似乎在说——学问的路，才刚刚开始。',
        isEnding: true,
        endingType: 'normal',
      ),
    },
  );
}

Story _shijingStory() {
  return Story(
    characterId: 'shijing',
    title: '情丝花海',
    description: '追寻歌声，来到被沙暴包围的绿洲',
    startNodeId: 'start',
    nodes: {
      'start': StoryNode(
        id: 'start',
        speaker: '旁白',
        text: '你途经一片荒漠，忽然听到若有若无的歌声。循着歌声走去，你发现了一座被沙暴包围的绿洲。绿洲中央，一位青衣女子站在祭坛上。',
        choices: [
          StoryChoice(text: '静静聆听歌声', affinityChange: 10, nextNodeId: 'listen'),
          StoryChoice(text: '上前询问', affinityChange: 5, nextNodeId: 'approach'),
        ],
      ),
      'listen': StoryNode(
        id: 'listen',
        speaker: '诗经',
        expression: 'normal',
        text: '……关关雎鸠，在河之洲。窈窕淑女，君子好逑。',
        choices: [
          StoryChoice(text: '这是《关雎》！', affinityChange: 8, nextNodeId: 'recognize'),
          StoryChoice(text: '继续静静听', affinityChange: 5, nextNodeId: 'keep_listening'),
        ],
      ),
      'approach': StoryNode(
        id: 'approach',
        speaker: '诗经',
        expression: 'thinking',
        text: '你……能听到我的歌声？这沙暴之外，还有人记得诗吗？',
        choices: [
          StoryChoice(text: '记得！我喜欢诗', affinityChange: 10, nextNodeId: 'love_poetry'),
          StoryChoice(text: '我只是路过', affinityChange: 0, nextNodeId: 'just_passing'),
        ],
      ),
      'recognize': StoryNode(
        id: 'recognize',
        speaker: '诗经',
        expression: 'smile',
        text: '你认得这首诗？太好了……情丝花海枯萎了太久，我以为再也没人记得了。',
        choices: [
          StoryChoice(text: '花海怎么了？', affinityChange: 5, nextNodeId: 'ask_huahai'),
          StoryChoice(text: '我能帮什么忙吗？', affinityChange: 10, nextNodeId: 'want_help'),
        ],
      ),
      'keep_listening': StoryNode(
        id: 'keep_listening',
        speaker: '诗经',
        expression: 'normal',
        text: '歌声渐歇，女子转过身来，眼中有泪光。她说：「谢谢你，愿意听我唱完。」',
        choices: [
          StoryChoice(text: '你唱得很好听', affinityChange: 8, nextNodeId: 'compliment'),
        ],
      ),
      'love_poetry': StoryNode(
        id: 'love_poetry',
        speaker: '诗经',
        expression: 'smile',
        text: '真的吗？那……你最喜欢哪一首？是《蒹葭》的秋水伊人，还是《硕鼠》的率真讽刺？',
        choices: [
          StoryChoice(text: '我喜欢《蒹葭》', affinityChange: 8, nextNodeId: 'like_jianjia'),
          StoryChoice(text: '都喜欢！', affinityChange: 10, nextNodeId: 'like_all'),
        ],
      ),
      'just_passing': StoryNode(
        id: 'just_passing',
        speaker: '诗经',
        expression: 'normal',
        text: '路过也好。能在荒漠中相遇，也是缘分。你……愿意听我唱一支歌吗？',
        choices: [
          StoryChoice(text: '愿意', affinityChange: 5, nextNodeId: 'listen'),
          StoryChoice(text: '我还有事……', affinityChange: -5, nextNodeId: 'leave_early'),
        ],
      ),
      'ask_huahai': StoryNode(
        id: 'ask_huahai',
        speaker: '诗经',
        expression: 'sad',
        text: '遗忘之影污染了花海，花朵枯萎，生灵们都忘了喜怒哀乐……我在用歌声勉强维持着这片绿洲。',
        choices: [
          StoryChoice(text: '我帮你一起收集诗魂吧', affinityChange: 10, nextNodeId: 'want_help'),
        ],
      ),
      'want_help': StoryNode(
        id: 'want_help',
        speaker: '诗经',
        expression: 'smile',
        text: '真的愿意帮我？太好了……每一首诗，都是一片诗魂。收集得越多，花海就能恢复得越多。',
        choices: [
          StoryChoice(text: '我们走吧！', affinityChange: 5, nextNodeId: 'good_ending'),
        ],
      ),
      'compliment': StoryNode(
        id: 'compliment',
        speaker: '诗经',
        expression: 'smile',
        text: '谢谢你的夸奖。诗啊，就是要有人听，才有意义。每一个愿意听的人，都是诗的知音。',
        choices: [
          StoryChoice(text: '那我愿意做你的知音', affinityChange: 8, nextNodeId: 'good_ending'),
        ],
      ),
      'like_jianjia': StoryNode(
        id: 'like_jianjia',
        speaker: '诗经',
        expression: 'smile',
        text: '《蒹葭》啊……"所谓伊人，在水一方"。那种求而不得的美，最让人难忘。你也有想追寻的东西吗？',
        choices: [
          StoryChoice(text: '有，一直在路上', affinityChange: 8, nextNodeId: 'good_ending'),
        ],
      ),
      'like_all': StoryNode(
        id: 'like_all',
        speaker: '诗经',
        expression: 'smile',
        text: '呵呵，贪心的小家伙。不过我喜欢——诗三百，各有各的好。就像这世间的情感，每一种都值得被记住。',
        choices: [
          StoryChoice(text: '嗯！每一种情感都珍贵', affinityChange: 10, nextNodeId: 'good_ending'),
        ],
      ),
      'leave_early': StoryNode(
        id: 'leave_early',
        speaker: '诗经',
        expression: 'sad',
        text: '这样啊……那，一路平安。如果哪天你想听歌了，就来情丝花海找我。',
        isEnding: true,
        endingType: 'bad',
      ),
      'good_ending': StoryNode(
        id: 'good_ending',
        speaker: '旁白',
        text: '你和诗经一起收集诗魂碎片。一片、两片……情丝花海渐渐恢复了生机，彩色的花朵重新绽放。你发现，那些被遗忘的情感，其实一直都在——只是需要有人，轻轻唱出来。',
        isEnding: true,
        endingType: 'good',
      ),
    },
  );
}

Story _shangshuStory() {
  return Story(
    characterId: 'shangshu',
    title: '隐居庄园',
    description: '寻找隐居的政治家，说服他重出江湖',
    startNodeId: 'start',
    nodes: {
      'start': StoryNode(
        id: 'start',
        speaker: '旁白',
        text: '根据周易的指引，你来到一座幽静的庄园。院中一位紫衣男子正在读书，气质雍容，不怒自威。',
        choices: [
          StoryChoice(text: '恭敬地说明来意', affinityChange: 5, nextNodeId: 'respectful'),
          StoryChoice(text: '先观察一番', affinityChange: 3, nextNodeId: 'observe'),
        ],
      ),
      'respectful': StoryNode(
        id: 'respectful',
        speaker: '尚书',
        expression: 'normal',
        text: '……你是周易派来的？说吧，找我何事。',
        choices: [
          StoryChoice(text: '想请先生出山救典籍大陆', affinityChange: 5, nextNodeId: 'ask_help'),
          StoryChoice(text: '想向先生请教治国之道', affinityChange: 8, nextNodeId: 'ask_governance'),
        ],
      ),
      'observe': StoryNode(
        id: 'observe',
        speaker: '尚书',
        expression: 'thinking',
        text: '看了这么久，可看出什么了？出来吧。',
        choices: [
          StoryChoice(text: '先生好眼力，失礼了', affinityChange: 5, nextNodeId: 'respectful'),
          StoryChoice(text: '先生读的是什么书？', affinityChange: 3, nextNodeId: 'ask_book'),
        ],
      ),
      'ask_help': StoryNode(
        id: 'ask_help',
        speaker: '尚书',
        expression: 'thinking',
        text: '救典籍大陆？我已隐居多年，不问世事。更何况……当年我被疑之时，可有人信我？',
        choices: [
          StoryChoice(text: '先生的委屈我理解', affinityChange: 10, nextNodeId: 'understand_pain'),
          StoryChoice(text: '现在情况紧急', affinityChange: 0, nextNodeId: 'urgent'),
        ],
      ),
      'ask_governance': StoryNode(
        id: 'ask_governance',
        speaker: '尚书',
        expression: 'smile',
        text: '治国之道？呵呵，倒是个有志向的年轻人。治国的根本，在于"克明俊德"——先修己身，再亲九族，再平天下。',
        choices: [
          StoryChoice(text: '请先生详解', affinityChange: 8, nextNodeId: 'explain_governance'),
          StoryChoice(text: '修身齐家治国平天下，我懂', affinityChange: 3, nextNodeId: 'know_daxue'),
        ],
      ),
      'ask_book': StoryNode(
        id: 'ask_book',
        speaker: '尚书',
        expression: 'normal',
        text: '不过是些旧文罢了。你若有兴趣，不妨说说你找我的真正目的。',
        choices: [
          StoryChoice(text: '实不相瞒，是来请先生出山', affinityChange: 5, nextNodeId: 'ask_help'),
        ],
      ),
      'understand_pain': StoryNode(
        id: 'understand_pain',
        speaker: '尚书',
        expression: 'sad',
        text: '……你倒是第一个说理解的人。罢了，我问你——若你做了好事却被人误解，你还会继续做吗？',
        choices: [
          StoryChoice(text: '会，问心无愧就好', affinityChange: 10, nextNodeId: 'answer_yes'),
          StoryChoice(text: '可能会犹豫', affinityChange: 5, nextNodeId: 'answer_hesitate'),
        ],
      ),
      'urgent': StoryNode(
        id: 'urgent',
        speaker: '尚书',
        expression: 'normal',
        text: '紧急？天下之事，欲速则不达。越是紧急，越要沉得住气。你且坐下，慢慢说。',
        choices: [
          StoryChoice(text: '是晚辈心急了', affinityChange: 5, nextNodeId: 'understand_pain'),
        ],
      ),
      'explain_governance': StoryNode(
        id: 'explain_governance',
        speaker: '尚书',
        expression: 'normal',
        text: '详解？《尧典》说得明白："克明俊德，以亲九族。九族既睦，平章百姓。百姓昭明，协和万邦。"由近及远，由内及外。',
        choices: [
          StoryChoice(text: '先生说得透彻', affinityChange: 5, nextNodeId: 'good_ending'),
        ],
      ),
      'know_daxue': StoryNode(
        id: 'know_daxue',
        speaker: '尚书',
        expression: 'smile',
        text: '哦？你也读过《大学》？知其然更要知其所以然。你可知为何要从修身开始？',
        choices: [
          StoryChoice(text: '因为身正才能令行', affinityChange: 8, nextNodeId: 'good_ending'),
          StoryChoice(text: '愿闻其详', affinityChange: 5, nextNodeId: 'explain_governance'),
        ],
      ),
      'answer_yes': StoryNode(
        id: 'answer_yes',
        speaker: '尚书',
        expression: 'smile',
        text: '问心无愧……好！说得好。我隐居多年，倒是被你点醒了。也罢，就随你走一遭。',
        choices: [
          StoryChoice(text: '多谢先生！', affinityChange: 5, nextNodeId: 'good_ending'),
        ],
      ),
      'answer_hesitate': StoryNode(
        id: 'answer_hesitate',
        speaker: '尚书',
        expression: 'normal',
        text: '犹豫也是人之常情。不过——犹豫之后还选择前行，才是真正的担当。你说是吗？',
        choices: [
          StoryChoice(text: '先生说得是', affinityChange: 5, nextNodeId: 'normal_ending'),
        ],
      ),
      'good_ending': StoryNode(
        id: 'good_ending',
        speaker: '旁白',
        text: '尚书终于同意出山。紫衣飘飘，他走在你身旁，仿佛又变回了那个指点江山的政治家。也许，他等这一天，已经等了很久。',
        isEnding: true,
        endingType: 'good',
      ),
      'normal_ending': StoryNode(
        id: 'normal_ending',
        speaker: '旁白',
        text: '你与尚书长谈了许久。虽然他还没有答应出山，但你能感觉到，他心中的坚冰，正在慢慢融化。也许，下次再来，答案会不一样。',
        isEnding: true,
        endingType: 'normal',
      ),
    },
  );
}

Story _zhouliStory() {
  return Story(
    characterId: 'zhouli',
    title: '礼域议事',
    description: '进入礼域，参与三礼家族的复兴辩论',
    startNodeId: 'start',
    nodes: {
      'start': StoryNode(
        id: 'start',
        speaker: '旁白',
        text: '你踏入礼域，便觉一股端庄肃穆之气。议政堂内，三位礼家传人正在激烈争论。居中的女子见你进来，微微颔首。',
        choices: [
          StoryChoice(text: '行礼说明来意', affinityChange: 10, nextNodeId: 'proper_greeting'),
          StoryChoice(text: '好奇地问他们在争什么', affinityChange: 3, nextNodeId: 'ask_argument'),
        ],
      ),
      'proper_greeting': StoryNode(
        id: 'proper_greeting',
        speaker: '周礼',
        expression: 'smile',
        text: '好，知礼而来。你就是传说中的传礼者？来得正好，我们正有一事不决。',
        choices: [
          StoryChoice(text: '请讲', affinityChange: 5, nextNodeId: 'explain_conflict'),
        ],
      ),
      'ask_argument': StoryNode(
        id: 'ask_argument',
        speaker: '周礼',
        expression: 'normal',
        text: '争什么？争礼该如何复兴。仪礼重形式，礼记重义理，而我……重制度。',
        choices: [
          StoryChoice(text: '那先生觉得哪个重要？', affinityChange: 5, nextNodeId: 'explain_conflict'),
          StoryChoice(text: '我觉得都重要', affinityChange: 8, nextNodeId: 'both_important'),
        ],
      ),
      'explain_conflict': StoryNode(
        id: 'explain_conflict',
        speaker: '周礼',
        expression: 'normal',
        text: '礼域要复兴。仪礼说要恢复礼仪程序，礼记说要阐发礼学义理，我说要建立官制政典。三方各执一词。',
        choices: [
          StoryChoice(text: '我觉得应该三者结合', affinityChange: 10, nextNodeId: 'propose_combine'),
          StoryChoice(text: '制度最重要，没有规矩不成方圆', affinityChange: 8, nextNodeId: 'agree_zhouli'),
        ],
      ),
      'both_important': StoryNode(
        id: 'both_important',
        speaker: '周礼',
        expression: 'smile',
        text: '哦？都重要？说得轻巧。你倒说说，三者如何兼顾？',
        choices: [
          StoryChoice(text: '制度为骨，仪式为形，义理为魂', affinityChange: 12, nextNodeId: 'brilliant_answer'),
          StoryChoice(text: '嗯……我还没想好', affinityChange: 0, nextNodeId: 'not_sure'),
        ],
      ),
      'propose_combine': StoryNode(
        id: 'propose_combine',
        speaker: '周礼',
        expression: 'smile',
        text: '结合？怎么个结合法？说得具体些。',
        choices: [
          StoryChoice(text: '先生掌制度，仪礼掌仪式，礼记掌义理', affinityChange: 8, nextNodeId: 'good_proposal'),
        ],
      ),
      'agree_zhouli': StoryNode(
        id: 'agree_zhouli',
        speaker: '周礼',
        expression: 'smile',
        text: '呵呵，你倒是与我所见略同。不过，光有制度也不行——没有义理的制度是僵硬的，没有仪式的制度是空泛的。',
        choices: [
          StoryChoice(text: '先生说得对，三者缺一不可', affinityChange: 8, nextNodeId: 'good_proposal'),
        ],
      ),
      'brilliant_answer': StoryNode(
        id: 'brilliant_answer',
        speaker: '周礼',
        expression: 'smile',
        text: '制度为骨，仪式为形，义理为魂……好！说得太好了！这个比喻，我记下了。',
        choices: [
          StoryChoice(text: '多谢先生夸奖', affinityChange: 5, nextNodeId: 'good_ending'),
        ],
      ),
      'not_sure': StoryNode(
        id: 'not_sure',
        speaker: '周礼',
        expression: 'normal',
        text: '没想好也正常。这道题，我们争了几百年也没争明白。你且听听，再做判断。',
        choices: [
          StoryChoice(text: '好', affinityChange: 3, nextNodeId: 'explain_conflict'),
        ],
      ),
      'good_proposal': StoryNode(
        id: 'good_proposal',
        speaker: '周礼',
        expression: 'normal',
        text: '分工合作，各展所长……嗯，倒是个可行的方案。看来你这位传礼者，还真有几分见识。',
        choices: [
          StoryChoice(text: '不敢当', affinityChange: 5, nextNodeId: 'good_ending'),
        ],
      ),
      'good_ending': StoryNode(
        id: 'good_ending',
        speaker: '旁白',
        text: '周礼采纳了你的建议，三礼终于达成共识。礼域的钟声响起，象征着新的开始。你望着议政堂内忙碌的身影，心想——制度之美，在于让每个人都能发挥所长。',
        isEnding: true,
        endingType: 'good',
      ),
      'normal_ending': StoryNode(
        id: 'normal_ending',
        speaker: '旁白',
        text: '礼域的争论还在继续，但你带来的新视角，似乎让一切有了转机。也许下次再来，就能看到一个不一样的礼域。',
        isEnding: true,
        endingType: 'normal',
      ),
    },
  );
}

Story _xiaojingStory() {
  return Story(
    characterId: 'xiaojing',
    title: '孝域之谜',
    description: '进入田园般的孝域，发现看似完美背后的秘密',
    startNodeId: 'start',
    nodes: {
      'start': StoryNode(
        id: 'start',
        speaker: '旁白',
        text: '你来到孝域，这里田园阡陌，炊烟袅袅，一派安宁祥和。但周易的卦象说——此地无一人质疑，无一人说不。路边一位橙衣少年正在扫地。',
        choices: [
          StoryChoice(text: '友好地打招呼', affinityChange: 8, nextNodeId: 'friendly_hello'),
          StoryChoice(text: '观察一下再说话', affinityChange: 5, nextNodeId: 'observe_first'),
        ],
      ),
      'friendly_hello': StoryNode(
        id: 'friendly_hello',
        speaker: '孝经',
        expression: 'normal',
        text: '你好！你是外来的客人吧？我叫孝经。这里是孝域，欢迎你来！',
        choices: [
          StoryChoice(text: '这里的人都好孝顺的样子', affinityChange: 5, nextNodeId: 'comment_filial'),
          StoryChoice(text: '你一个人扫地吗？', affinityChange: 8, nextNodeId: 'ask_alone'),
        ],
      ),
      'observe_first': StoryNode(
        id: 'observe_first',
        speaker: '孝经',
        expression: 'thinking',
        text: '喂！你看了我半天了，有什么事吗？',
        choices: [
          StoryChoice(text: '抱歉，我只是觉得这里很特别', affinityChange: 5, nextNodeId: 'special_place'),
          StoryChoice(text: '没什么，路过', affinityChange: 0, nextNodeId: 'just_pass'),
        ],
      ),
      'comment_filial': StoryNode(
        id: 'comment_filial',
        speaker: '孝经',
        expression: 'normal',
        text: '那当然！孝域的人最孝顺了。不过……你不觉得，这里有点太"完美"了吗？',
        choices: [
          StoryChoice(text: '完美不好吗？', affinityChange: 3, nextNodeId: 'perfect_good'),
          StoryChoice(text: '确实感觉有点不对劲', affinityChange: 10, nextNodeId: 'feel_wrong'),
        ],
      ),
      'ask_alone': StoryNode(
        id: 'ask_alone',
        speaker: '孝经',
        expression: 'sad',
        text: '嗯……其他人都……很"乖"。乖到有点没意思。你不一样，你是外来的，会有自己的想法对吧？',
        choices: [
          StoryChoice(text: '什么意思？', affinityChange: 5, nextNodeId: 'ask_meaning'),
          StoryChoice(text: '我是有自己的想法', affinityChange: 10, nextNodeId: 'have_own_thoughts'),
        ],
      ),
      'special_place': StoryNode(
        id: 'special_place',
        speaker: '孝经',
        expression: 'normal',
        text: '特别？是啊……特别到没人敢说"不"。你说，孝就是什么都听父母的吗？',
        choices: [
          StoryChoice(text: '也不是，要有自己的判断', affinityChange: 10, nextNodeId: 'have_judgment'),
          StoryChoice(text: '孝顺孝顺，顺着就是孝吧', affinityChange: 0, nextNodeId: 'obey_is_xiao'),
        ],
      ),
      'just_pass': StoryNode(
        id: 'just_pass',
        speaker: '孝经',
        expression: 'normal',
        text: '路过？那你可来对地方了。孝域什么都好，就是……太安静了。连反对的声音都没有。',
        choices: [
          StoryChoice(text: '为什么没有反对的声音？', affinityChange: 5, nextNodeId: 'ask_meaning'),
        ],
      ),
      'perfect_good': StoryNode(
        id: 'perfect_good',
        speaker: '孝经',
        expression: 'thinking',
        text: '完美当然好，但如果完美到没有人敢说真话，那还是真的完美吗？我有时候会想……',
        choices: [
          StoryChoice(text: '想什么？', affinityChange: 8, nextNodeId: 'think_what'),
        ],
      ),
      'feel_wrong': StoryNode(
        id: 'feel_wrong',
        speaker: '孝经',
        expression: 'smile',
        text: '你也感觉到了？太好了！我还以为只有我觉得奇怪。这里的人都太"乖"了，乖到不像活人。',
        choices: [
          StoryChoice(text: '发生了什么？', affinityChange: 5, nextNodeId: 'ask_meaning'),
        ],
      ),
      'ask_meaning': StoryNode(
        id: 'ask_meaning',
        speaker: '孝经',
        expression: 'sad',
        text: '遗忘之影把"孝"变成了不容置疑的规矩。人们只会顺从，不会思考。我被困在中间，不知道怎么办……',
        choices: [
          StoryChoice(text: '真正的孝是什么？', affinityChange: 10, nextNodeId: 'true_xiao'),
        ],
      ),
      'have_own_thoughts': StoryNode(
        id: 'have_own_thoughts',
        speaker: '孝经',
        expression: 'smile',
        text: '真的吗？太好了！你能帮我一个忙吗？我想知道——真正的孝，到底是什么？',
        choices: [
          StoryChoice(text: '我想想……', affinityChange: 5, nextNodeId: 'true_xiao'),
        ],
      ),
      'have_judgment': StoryNode(
        id: 'have_judgment',
        speaker: '孝经',
        expression: 'smile',
        text: '对！我也是这么想的！"父有过，则谏诤"——父母有错，孩子应该指出来，那才是真的孝。',
        choices: [
          StoryChoice(text: '你懂得好多', affinityChange: 8, nextNodeId: 'good_ending'),
        ],
      ),
      'obey_is_xiao': StoryNode(
        id: 'obey_is_xiao',
        speaker: '孝经',
        expression: 'thinking',
        text: '是吗……可是如果父母做得不对，也要顺着吗？那不是害了他们吗？我觉得……孝不是盲从。',
        choices: [
          StoryChoice(text: '你说得有道理', affinityChange: 8, nextNodeId: 'good_ending'),
        ],
      ),
      'think_what': StoryNode(
        id: 'think_what',
        speaker: '孝经',
        expression: 'normal',
        text: '我在想，孝是不是应该从心出发，而不是从规矩出发。心里真正装着亲人，才是真的孝。',
        choices: [
          StoryChoice(text: '我同意，孝在心不在礼', affinityChange: 10, nextNodeId: 'good_ending'),
        ],
      ),
      'true_xiao': StoryNode(
        id: 'true_xiao',
        speaker: '孝经',
        expression: 'normal',
        text: '真正的孝？我觉得……是爱，是敬，是让亲人变得更好。不是一味顺从，也不是刻板规矩。是发自内心的关心。',
        choices: [
          StoryChoice(text: '说得好！', affinityChange: 10, nextNodeId: 'good_ending'),
        ],
      ),
      'good_ending': StoryNode(
        id: 'good_ending',
        speaker: '旁白',
        text: '你和孝经聊了很久。渐渐地，你发现孝域的空气中似乎有什么在松动——那些"完美"的笑容里，开始有了真实的表情。也许，真正的孝道，从来不是规训，而是发自内心的爱与敬。',
        isEnding: true,
        endingType: 'good',
      ),
      'normal_ending': StoryNode(
        id: 'normal_ending',
        speaker: '旁白',
        text: '你告别了孝经，离开了孝域。回头望去，那片田园依旧安宁，但你知道——有一颗质疑的种子，已经在少年心中发芽。',
        isEnding: true,
        endingType: 'normal',
      ),
    },
  );
}

Story? getStoryByCharacterId(String characterId) {
  return getStories()[characterId];
}
