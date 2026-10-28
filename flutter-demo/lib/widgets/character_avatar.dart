import 'package:flutter/material.dart';
import '../models/character.dart';

class CharacterAvatar extends StatelessWidget {
  final Character character;
  final double size;
  final bool showName;
  final String expression;

  const CharacterAvatar({
    super.key,
    required this.character,
    this.size = 80,
    this.showName = false,
    this.expression = 'normal',
  });

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Color(int.parse('FF${character.primaryColor}', radix: 16));
    Color secondaryColor = Color(int.parse('FF${character.secondaryColor}', radix: 16));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, secondaryColor],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: character.imagePath != null
              ? ClipOval(
                  child: Image.asset(
                    character.imagePath!,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildTextAvatar(primaryColor, size);
                    },
                  ),
                )
              : _buildTextAvatar(primaryColor, size),
        ),
        if (showName) ...[
          const SizedBox(height: 8),
          Text(
            character.classicName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextAvatar(Color primaryColor, double size) {
    return Center(
      child: Text(
        character.name.substring(0, 1),
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }
}
