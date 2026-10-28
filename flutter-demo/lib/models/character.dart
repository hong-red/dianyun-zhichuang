class Character {
  final String id;
  final String name;
  final String classicName;
  final int age;
  final String personality;
  final String description;
  final String avatarColor;
  final String primaryColor;
  final String secondaryColor;
  final String systemPrompt;
  final String famousQuote;
  final String roleType;
  final String? imagePath;

  const Character({
    required this.id,
    required this.name,
    required this.classicName,
    required this.age,
    required this.personality,
    required this.description,
    required this.avatarColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.systemPrompt,
    required this.famousQuote,
    required this.roleType,
    this.imagePath,
  });
}
