class StoryChoice {
  final String text;
  final int affinityChange;
  final String nextNodeId;

  StoryChoice({
    required this.text,
    required this.affinityChange,
    required this.nextNodeId,
  });
}

class StoryNode {
  final String id;
  final String speaker;
  final String text;
  final String? expression;
  final List<StoryChoice> choices;
  final bool isEnding;
  final String? endingType;

  StoryNode({
    required this.id,
    required this.speaker,
    required this.text,
    this.expression,
    this.choices = const [],
    this.isEnding = false,
    this.endingType,
  });
}

class Story {
  final String characterId;
  final String title;
  final String description;
  final Map<String, StoryNode> nodes;
  final String startNodeId;

  Story({
    required this.characterId,
    required this.title,
    required this.description,
    required this.nodes,
    required this.startNodeId,
  });
}
