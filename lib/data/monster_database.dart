import 'package:flutter/material.dart';

class DndClassInfo {
  final String name;
  final String description;
  final int hitDie;
  final int defaultAc;
  final IconData icon;
  final Color color;

  const DndClassInfo({
    required this.name,
    required this.description,
    required this.hitDie,
    required this.defaultAc,
    required this.icon,
    required this.color,
  });
}

/// As 12 Classes Oficiais do D&D 5.5e (Livro do Jogador 2024)
const List<DndClassInfo> dndClasses = [
  DndClassInfo(
    name: 'Bárbaro',
    description: 'Fúria primal, Defesa sem Armadura e Maestria em Armas',
    hitDie: 12,
    defaultAc: 14,
    icon: Icons.fitness_center,
    color: Color(0xFFFF8A65), // Terracota / Coral Cobre (diferente do vermelho de monstro)
  ),
  DndClassInfo(
    name: 'Bardo',
    description: 'Inspiração de Bardo, perícia versátil e magia arcana',
    hitDie: 8,
    defaultAc: 14,
    icon: Icons.music_note,
    color: Color(0xFFF06292), // Rosa / Magenta Suave
  ),
  DndClassInfo(
    name: 'Bruxo',
    description: 'Magia de Pacto, Invocações Místicas e Patrono Sobrenatural',
    hitDie: 8,
    defaultAc: 14,
    icon: Icons.auto_fix_high,
    color: Color(0xFFB39DDB), // Roxo / Lilás Místico Suave
  ),
  DndClassInfo(
    name: 'Clérigo',
    description: 'Ordem Divina (Protetor/Taumaturgo) e Canalizar Divindade',
    hitDie: 8,
    defaultAc: 17,
    icon: Icons.wb_sunny,
    color: Color(0xFFFFD54F), // Dourado Solar Suave
  ),
  DndClassInfo(
    name: 'Druida',
    description: 'Ordem Primal (Guardião/Xamã) e Forma Selvagem 5.5e',
    hitDie: 8,
    defaultAc: 15,
    icon: Icons.eco,
    color: Color(0xFF81C784), // Verde Natureza Suave
  ),
  DndClassInfo(
    name: 'Feiticeiro',
    description: 'Feitiçaria Inata, Pontos de Feitiçaria e Metamagia',
    hitDie: 6,
    defaultAc: 13,
    icon: Icons.bolt,
    color: Color(0xFFFFB74D), // Âmbar Arcano Suave
  ),
  DndClassInfo(
    name: 'Guardião (Patrulheiro)',
    description: 'Inimigo Favorito, Magia Primal e Maestria em Armas',
    hitDie: 10,
    defaultAc: 15,
    icon: Icons.forest,
    color: Color(0xFFA5D6A7), // Verde Floresta / Musgo Suave
  ),
  DndClassInfo(
    name: 'Guerreiro',
    description: 'Retomar o Fôlego, Surto de Ação e Maestria Tática',
    hitDie: 10,
    defaultAc: 17,
    icon: Icons.shield,
    color: Color(0xFFBCAAA4), // Bronze / Aço Suave
  ),
  DndClassInfo(
    name: 'Ladino',
    description: 'Ataque Furtivo, Golpe Astuto e Maestria em Armas',
    hitDie: 8,
    defaultAc: 15,
    icon: Icons.visibility_off,
    color: Color(0xFF90A4AE), // Prata / Cinza-Azulado
  ),
  DndClassInfo(
    name: 'Mago',
    description: 'Grimório Arcano, Memorizar Magia e Recuperação Arcana',
    hitDie: 6,
    defaultAc: 13,
    icon: Icons.menu_book,
    color: Color(0xFF64B5F6), // Azul Arcano Suave
  ),
  DndClassInfo(
    name: 'Monge',
    description: 'Artes Marciais, Pontos de Foco e Defletir Ataques',
    hitDie: 8,
    defaultAc: 16,
    icon: Icons.self_improvement,
    color: Color(0xFF4DD0E1), // Ciano / Turquesa Ki
  ),
  DndClassInfo(
    name: 'Paladino',
    description: 'Imposição das Mãos, Destruição Divina e Juramento Sagrado',
    hitDie: 10,
    defaultAc: 18,
    icon: Icons.security,
    color: Color(0xFFFFE082), // Ouro Sagrado Suave
  ),
];

DndClassInfo? getDndClassInfo(String? className) {
  if (className == null || className.isEmpty) return null;
  final normalized = className.trim().toLowerCase();
  for (final c in dndClasses) {
    if (c.name.toLowerCase() == normalized ||
        normalized.contains(c.name.toLowerCase()) ||
        c.name.toLowerCase().contains(normalized)) {
      return c;
    }
  }
  return null;
}

class MonsterTemplate {
  final String name;
  final String type;
  final String challengeRating;
  final int armorClass;
  final int hpMax;
  final int initiativeBonus;

  const MonsterTemplate({
    required this.name,
    required this.type,
    required this.challengeRating,
    required this.armorClass,
    required this.hpMax,
    required this.initiativeBonus,
  });
}

/// Base de Monstros D&D 5.5e (Manual dos Monstros 2024/2025 - SRD 5.2)
const List<MonsterTemplate> monsterDatabase = [
  // Goblinoides (Fada no D&D 5.5e)
  MonsterTemplate(name: 'Goblin Lacaio (Minion)', type: 'Fada', challengeRating: '1/8', armorClass: 12, hpMax: 7, initiativeBonus: 2),
  MonsterTemplate(name: 'Goblin Guerreiro', type: 'Fada', challengeRating: '1/4', armorClass: 15, hpMax: 10, initiativeBonus: 2),
  MonsterTemplate(name: 'Goblin Chefe', type: 'Fada', challengeRating: '1', armorClass: 17, hpMax: 21, initiativeBonus: 2),
  MonsterTemplate(name: 'Goblin Bruxo (Hexer)', type: 'Fada', challengeRating: '3', armorClass: 13, hpMax: 45, initiativeBonus: 3),
  MonsterTemplate(name: 'Hobgoblin Guerreiro', type: 'Fada', challengeRating: '1/2', armorClass: 18, hpMax: 11, initiativeBonus: 3),
  MonsterTemplate(name: 'Hobgoblin Capitão', type: 'Fada', challengeRating: '3', armorClass: 17, hpMax: 58, initiativeBonus: 4),
  MonsterTemplate(name: 'Hobgoblin Senhor da Guerra', type: 'Fada', challengeRating: '6', armorClass: 20, hpMax: 112, initiativeBonus: 5),
  MonsterTemplate(name: 'Bugbear Guerreiro', type: 'Fada', challengeRating: '1', armorClass: 14, hpMax: 33, initiativeBonus: 2),
  MonsterTemplate(name: 'Bugbear Espreitador', type: 'Fada', challengeRating: '3', armorClass: 15, hpMax: 65, initiativeBonus: 3),

  // Kobolds & Draconianos (Dragão no D&D 5.5e)
  MonsterTemplate(name: 'Kobold Guerreiro', type: 'Dragão', challengeRating: '1/8', armorClass: 14, hpMax: 7, initiativeBonus: 2),
  MonsterTemplate(name: 'Kobold Alquimista', type: 'Dragão', challengeRating: '1', armorClass: 13, hpMax: 27, initiativeBonus: 3),
  MonsterTemplate(name: 'Meio-Dragão', type: 'Dragão', challengeRating: '5', armorClass: 18, hpMax: 105, initiativeBonus: 5),
  MonsterTemplate(name: 'Wyvern', type: 'Dragão', challengeRating: '6', armorClass: 14, hpMax: 110, initiativeBonus: 0),
  MonsterTemplate(name: 'Dragão Branco Filhote', type: 'Dragão', challengeRating: '2', armorClass: 16, hpMax: 32, initiativeBonus: 2),
  MonsterTemplate(name: 'Dragão Negro Filhote', type: 'Dragão', challengeRating: '2', armorClass: 17, hpMax: 33, initiativeBonus: 4),
  MonsterTemplate(name: 'Dragão Verde Filhote', type: 'Dragão', challengeRating: '2', armorClass: 17, hpMax: 38, initiativeBonus: 3),
  MonsterTemplate(name: 'Dragão Azul Filhote', type: 'Dragão', challengeRating: '3', armorClass: 17, hpMax: 52, initiativeBonus: 2),
  MonsterTemplate(name: 'Dragão Vermelho Filhote', type: 'Dragão', challengeRating: '4', armorClass: 17, hpMax: 75, initiativeBonus: 2),
  MonsterTemplate(name: 'Dragão Branco Jovem', type: 'Dragão', challengeRating: '6', armorClass: 17, hpMax: 133, initiativeBonus: 3),
  MonsterTemplate(name: 'Dragão Negro Jovem', type: 'Dragão', challengeRating: '7', armorClass: 18, hpMax: 127, initiativeBonus: 5),
  MonsterTemplate(name: 'Dragão Verde Jovem', type: 'Dragão', challengeRating: '8', armorClass: 18, hpMax: 136, initiativeBonus: 4),
  MonsterTemplate(name: 'Dragão Azul Jovem', type: 'Dragão', challengeRating: '9', armorClass: 18, hpMax: 152, initiativeBonus: 4),
  MonsterTemplate(name: 'Dragão Vermelho Jovem', type: 'Dragão', challengeRating: '10', armorClass: 18, hpMax: 178, initiativeBonus: 4),
  MonsterTemplate(name: 'Dragão Branco Adulto', type: 'Dragão', challengeRating: '13', armorClass: 18, hpMax: 200, initiativeBonus: 10),
  MonsterTemplate(name: 'Dragão Negro Adulto', type: 'Dragão', challengeRating: '14', armorClass: 19, hpMax: 195, initiativeBonus: 12),
  MonsterTemplate(name: 'Dragão Verde Adulto', type: 'Dragão', challengeRating: '15', armorClass: 19, hpMax: 207, initiativeBonus: 11),
  MonsterTemplate(name: 'Dragão Azul Adulto', type: 'Dragão', challengeRating: '16', armorClass: 19, hpMax: 225, initiativeBonus: 12),
  MonsterTemplate(name: 'Dragão Vermelho Adulto', type: 'Dragão', challengeRating: '17', armorClass: 19, hpMax: 256, initiativeBonus: 12),
  MonsterTemplate(name: 'Dragão Vermelho Ancião', type: 'Dragão', challengeRating: '24', armorClass: 22, hpMax: 546, initiativeBonus: 14),

  // Mortos-Vivos (D&D 5.5e)
  MonsterTemplate(name: 'Esqueleto', type: 'Morto-Vivo', challengeRating: '1/4', armorClass: 14, hpMax: 13, initiativeBonus: 2),
  MonsterTemplate(name: 'Esqueleto de Cavalo de Guerra', type: 'Morto-Vivo', challengeRating: '1/2', armorClass: 13, hpMax: 22, initiativeBonus: 1),
  MonsterTemplate(name: 'Esqueleto Minotauro', type: 'Morto-Vivo', challengeRating: '2', armorClass: 12, hpMax: 67, initiativeBonus: 0),
  MonsterTemplate(name: 'Zumbi', type: 'Morto-Vivo', challengeRating: '1/4', armorClass: 8, hpMax: 15, initiativeBonus: -2),
  MonsterTemplate(name: 'Zumbi Ogro', type: 'Morto-Vivo', challengeRating: '2', armorClass: 8, hpMax: 85, initiativeBonus: -2),
  MonsterTemplate(name: 'Carniçal (Ghoul)', type: 'Morto-Vivo', challengeRating: '1', armorClass: 12, hpMax: 22, initiativeBonus: 2),
  MonsterTemplate(name: 'Lívido (Ghast)', type: 'Morto-Vivo', challengeRating: '2', armorClass: 13, hpMax: 36, initiativeBonus: 3),
  MonsterTemplate(name: 'Sombra', type: 'Morto-Vivo', challengeRating: '1/2', armorClass: 12, hpMax: 27, initiativeBonus: 2),
  MonsterTemplate(name: 'Espectro', type: 'Morto-Vivo', challengeRating: '1', armorClass: 12, hpMax: 22, initiativeBonus: 2),
  MonsterTemplate(name: 'Inumano (Wight)', type: 'Morto-Vivo', challengeRating: '3', armorClass: 14, hpMax: 82, initiativeBonus: 4),
  MonsterTemplate(name: 'Múmia', type: 'Morto-Vivo', challengeRating: '3', armorClass: 11, hpMax: 58, initiativeBonus: -1),
  MonsterTemplate(name: 'Fantasma', type: 'Morto-Vivo', challengeRating: '4', armorClass: 11, hpMax: 45, initiativeBonus: 1),
  MonsterTemplate(name: 'Banshee', type: 'Morto-Vivo', challengeRating: '4', armorClass: 12, hpMax: 58, initiativeBonus: 2),
  MonsterTemplate(name: 'Aparição (Wraith)', type: 'Morto-Vivo', challengeRating: '5', armorClass: 13, hpMax: 67, initiativeBonus: 3),
  MonsterTemplate(name: 'Cria Vampírica', type: 'Morto-Vivo', challengeRating: '5', armorClass: 16, hpMax: 90, initiativeBonus: 6),
  MonsterTemplate(name: 'Vampiro', type: 'Morto-Vivo', challengeRating: '13', armorClass: 16, hpMax: 195, initiativeBonus: 14),
  MonsterTemplate(name: 'Senhor das Múmias', type: 'Morto-Vivo', challengeRating: '15', armorClass: 17, hpMax: 187, initiativeBonus: 10),
  MonsterTemplate(name: 'Cavaleiro da Morte', type: 'Morto-Vivo', challengeRating: '17', armorClass: 20, hpMax: 199, initiativeBonus: 12),
  MonsterTemplate(name: 'Lich', type: 'Morto-Vivo', challengeRating: '21', armorClass: 20, hpMax: 315, initiativeBonus: 17),

  // Humanoides (D&D 5.5e)
  MonsterTemplate(name: 'Bandido', type: 'Humanoide', challengeRating: '1/8', armorClass: 12, hpMax: 11, initiativeBonus: 1),
  MonsterTemplate(name: 'Capitão dos Bandidos', type: 'Humanoide', challengeRating: '2', armorClass: 15, hpMax: 52, initiativeBonus: 3),
  MonsterTemplate(name: 'Guarda', type: 'Humanoide', challengeRating: '1/8', armorClass: 16, hpMax: 11, initiativeBonus: 1),
  MonsterTemplate(name: 'Capitão da Guarda', type: 'Humanoide', challengeRating: '4', armorClass: 18, hpMax: 75, initiativeBonus: 4),
  MonsterTemplate(name: 'Cultista', type: 'Humanoide', challengeRating: '1/8', armorClass: 12, hpMax: 9, initiativeBonus: 1),
  MonsterTemplate(name: 'Fanático do Culto', type: 'Humanoide', challengeRating: '2', armorClass: 13, hpMax: 44, initiativeBonus: 2),
  MonsterTemplate(name: 'Brutamontes (Tough)', type: 'Humanoide', challengeRating: '1/2', armorClass: 12, hpMax: 32, initiativeBonus: 1),
  MonsterTemplate(name: 'Chefe Brutamontes (Tough Boss)', type: 'Humanoide', challengeRating: '4', armorClass: 16, hpMax: 82, initiativeBonus: 2),
  MonsterTemplate(name: 'Batedor (Scout)', type: 'Humanoide', challengeRating: '1/2', armorClass: 13, hpMax: 16, initiativeBonus: 2),
  MonsterTemplate(name: 'Espião', type: 'Humanoide', challengeRating: '1', armorClass: 12, hpMax: 27, initiativeBonus: 4),
  MonsterTemplate(name: 'Pirata', type: 'Humanoide', challengeRating: '1', armorClass: 14, hpMax: 33, initiativeBonus: 5),
  MonsterTemplate(name: 'Capitão Pirata', type: 'Humanoide', challengeRating: '6', armorClass: 17, hpMax: 104, initiativeBonus: 7),
  MonsterTemplate(name: 'Berserker', type: 'Humanoide', challengeRating: '2', armorClass: 13, hpMax: 67, initiativeBonus: 1),
  MonsterTemplate(name: 'Sacerdote Acólito', type: 'Humanoide', challengeRating: '1/4', armorClass: 13, hpMax: 11, initiativeBonus: 0),
  MonsterTemplate(name: 'Sacerdote', type: 'Humanoide', challengeRating: '2', armorClass: 13, hpMax: 38, initiativeBonus: 0),
  MonsterTemplate(name: 'Cavaleiro', type: 'Humanoide', challengeRating: '3', armorClass: 18, hpMax: 52, initiativeBonus: 0),
  MonsterTemplate(name: 'Guerreiro Veterano', type: 'Humanoide', challengeRating: '3', armorClass: 17, hpMax: 65, initiativeBonus: 3),
  MonsterTemplate(name: 'Gladiador', type: 'Humanoide', challengeRating: '5', armorClass: 16, hpMax: 112, initiativeBonus: 5),
  MonsterTemplate(name: 'Mago Aprendiz', type: 'Humanoide', challengeRating: '2', armorClass: 15, hpMax: 49, initiativeBonus: 2),
  MonsterTemplate(name: 'Mago', type: 'Humanoide', challengeRating: '6', armorClass: 15, hpMax: 81, initiativeBonus: 2),
  MonsterTemplate(name: 'Assassino', type: 'Humanoide', challengeRating: '8', armorClass: 16, hpMax: 97, initiativeBonus: 7),
  MonsterTemplate(name: 'Arquimago', type: 'Humanoide', challengeRating: '12', armorClass: 17, hpMax: 170, initiativeBonus: 7),

  // Bestas (D&D 5.5e)
  MonsterTemplate(name: 'Rato Gigante', type: 'Besta', challengeRating: '1/8', armorClass: 13, hpMax: 7, initiativeBonus: 3),
  MonsterTemplate(name: 'Lobo', type: 'Besta', challengeRating: '1/4', armorClass: 12, hpMax: 11, initiativeBonus: 2),
  MonsterTemplate(name: 'Lobo Atroz (Dire Wolf)', type: 'Besta', challengeRating: '1', armorClass: 14, hpMax: 22, initiativeBonus: 2),
  MonsterTemplate(name: 'Aranha Gigante', type: 'Besta', challengeRating: '1', armorClass: 14, hpMax: 26, initiativeBonus: 3),
  MonsterTemplate(name: 'Urso Pardo', type: 'Besta', challengeRating: '1', armorClass: 11, hpMax: 22, initiativeBonus: 1),
  MonsterTemplate(name: 'Leão', type: 'Besta', challengeRating: '1', armorClass: 12, hpMax: 22, initiativeBonus: 2),
  MonsterTemplate(name: 'Tigre', type: 'Besta', challengeRating: '1', armorClass: 13, hpMax: 30, initiativeBonus: 3),
  MonsterTemplate(name: 'Urso Polar', type: 'Besta', challengeRating: '2', armorClass: 12, hpMax: 42, initiativeBonus: 2),
  MonsterTemplate(name: 'Cobra Constritora Gigante', type: 'Besta', challengeRating: '2', armorClass: 12, hpMax: 60, initiativeBonus: 2),
  MonsterTemplate(name: 'Crocodilo Gigante', type: 'Besta', challengeRating: '5', armorClass: 14, hpMax: 85, initiativeBonus: -1),
  MonsterTemplate(name: 'Mamute', type: 'Besta', challengeRating: '6', armorClass: 13, hpMax: 126, initiativeBonus: 2),
  MonsterTemplate(name: 'Tiranossauro Rex', type: 'Besta', challengeRating: '8', armorClass: 13, hpMax: 136, initiativeBonus: 3),

  // Monstruosidades (D&D 5.5e)
  MonsterTemplate(name: 'Harpia', type: 'Monstruosidade', challengeRating: '1', armorClass: 11, hpMax: 38, initiativeBonus: 1),
  MonsterTemplate(name: 'Hipogrifo', type: 'Monstruosidade', challengeRating: '1', armorClass: 11, hpMax: 26, initiativeBonus: 1),
  MonsterTemplate(name: 'Mímico (Mimic)', type: 'Monstruosidade', challengeRating: '2', armorClass: 12, hpMax: 58, initiativeBonus: 3),
  MonsterTemplate(name: 'Grifo', type: 'Monstruosidade', challengeRating: '2', armorClass: 12, hpMax: 59, initiativeBonus: 2),
  MonsterTemplate(name: 'Urso-Coruja (Owlbear)', type: 'Monstruosidade', challengeRating: '3', armorClass: 13, hpMax: 59, initiativeBonus: 1),
  MonsterTemplate(name: 'Pantera Deslocadora', type: 'Monstruosidade', challengeRating: '3', armorClass: 13, hpMax: 76, initiativeBonus: 2),
  MonsterTemplate(name: 'Manticora', type: 'Monstruosidade', challengeRating: '3', armorClass: 14, hpMax: 68, initiativeBonus: 3),
  MonsterTemplate(name: 'Minotauro', type: 'Monstruosidade', challengeRating: '3', armorClass: 14, hpMax: 85, initiativeBonus: 0),
  MonsterTemplate(name: 'Basilisco', type: 'Monstruosidade', challengeRating: '3', armorClass: 15, hpMax: 52, initiativeBonus: -1),
  MonsterTemplate(name: 'Doppelganger', type: 'Monstruosidade', challengeRating: '3', armorClass: 14, hpMax: 52, initiativeBonus: 4),
  MonsterTemplate(name: 'Aranha Etérea (Phase Spider)', type: 'Monstruosidade', challengeRating: '3', armorClass: 14, hpMax: 45, initiativeBonus: 3),
  MonsterTemplate(name: 'Bulette', type: 'Monstruosidade', challengeRating: '5', armorClass: 17, hpMax: 94, initiativeBonus: 0),
  MonsterTemplate(name: 'Górgona', type: 'Monstruosidade', challengeRating: '5', armorClass: 19, hpMax: 114, initiativeBonus: 0),
  MonsterTemplate(name: 'Medusa', type: 'Monstruosidade', challengeRating: '6', armorClass: 15, hpMax: 127, initiativeBonus: 5),
  MonsterTemplate(name: 'Quimera', type: 'Monstruosidade', challengeRating: '6', armorClass: 14, hpMax: 114, initiativeBonus: 0),
  MonsterTemplate(name: 'Hidra', type: 'Monstruosidade', challengeRating: '8', armorClass: 15, hpMax: 184, initiativeBonus: 4),
  MonsterTemplate(name: 'Kraken', type: 'Monstruosidade', challengeRating: '23', armorClass: 18, hpMax: 481, initiativeBonus: 14),
  MonsterTemplate(name: 'Tarrasque', type: 'Monstruosidade', challengeRating: '30', armorClass: 25, hpMax: 697, initiativeBonus: 18),

  // Gigantes (D&D 5.5e)
  MonsterTemplate(name: 'Ogro', type: 'Gigante', challengeRating: '2', armorClass: 11, hpMax: 68, initiativeBonus: -1),
  MonsterTemplate(name: 'Ettin', type: 'Gigante', challengeRating: '4', armorClass: 12, hpMax: 85, initiativeBonus: -1),
  MonsterTemplate(name: 'Troll', type: 'Gigante', challengeRating: '5', armorClass: 15, hpMax: 94, initiativeBonus: 1),
  MonsterTemplate(name: 'Gigante da Colina', type: 'Gigante', challengeRating: '5', armorClass: 13, hpMax: 105, initiativeBonus: 2),
  MonsterTemplate(name: 'Ciclope', type: 'Gigante', challengeRating: '6', armorClass: 14, hpMax: 138, initiativeBonus: 0),
  MonsterTemplate(name: 'Gigante de Pedra', type: 'Gigante', challengeRating: '7', armorClass: 17, hpMax: 126, initiativeBonus: 5),
  MonsterTemplate(name: 'Gigante do Gelo', type: 'Gigante', challengeRating: '8', armorClass: 15, hpMax: 149, initiativeBonus: 2),
  MonsterTemplate(name: 'Gigante do Fogo', type: 'Gigante', challengeRating: '9', armorClass: 18, hpMax: 162, initiativeBonus: 3),
  MonsterTemplate(name: 'Gigante das Nuvens', type: 'Gigante', challengeRating: '9', armorClass: 14, hpMax: 200, initiativeBonus: 4),
  MonsterTemplate(name: 'Gigante da Tempestade', type: 'Gigante', challengeRating: '13', armorClass: 16, hpMax: 230, initiativeBonus: 7),

  // Corruptores (Demônios, Diabos e Gnolls no D&D 5.5e)
  MonsterTemplate(name: 'Gnoll Guerreiro', type: 'Corruptor', challengeRating: '1/2', armorClass: 15, hpMax: 27, initiativeBonus: 1),
  MonsterTemplate(name: 'Gnoll Líder de Matilha', type: 'Corruptor', challengeRating: '2', armorClass: 15, hpMax: 49, initiativeBonus: 2),
  MonsterTemplate(name: 'Diabrete (Imp)', type: 'Corruptor', challengeRating: '1', armorClass: 13, hpMax: 21, initiativeBonus: 3),
  MonsterTemplate(name: 'Quasit', type: 'Corruptor', challengeRating: '1', armorClass: 13, hpMax: 25, initiativeBonus: 3),
  MonsterTemplate(name: 'Cão Infernal (Hell Hound)', type: 'Corruptor', challengeRating: '3', armorClass: 15, hpMax: 58, initiativeBonus: 1),
  MonsterTemplate(name: 'Diabo Barbuto', type: 'Corruptor', challengeRating: '3', armorClass: 13, hpMax: 58, initiativeBonus: 2),
  MonsterTemplate(name: 'Súcubo / Íncubo', type: 'Corruptor', challengeRating: '4', armorClass: 15, hpMax: 71, initiativeBonus: 3),
  MonsterTemplate(name: 'Oni', type: 'Corruptor', challengeRating: '7', armorClass: 17, hpMax: 119, initiativeBonus: 3),
  MonsterTemplate(name: 'Diabo dos Ossos', type: 'Corruptor', challengeRating: '9', armorClass: 16, hpMax: 161, initiativeBonus: 7),
  MonsterTemplate(name: 'Balor', type: 'Corruptor', challengeRating: '19', armorClass: 19, hpMax: 287, initiativeBonus: 14),
  MonsterTemplate(name: 'Senhor do Abismo (Pit Fiend)', type: 'Corruptor', challengeRating: '20', armorClass: 21, hpMax: 337, initiativeBonus: 14),

  // Aberrações & Limos (D&D 5.5e)
  MonsterTemplate(name: 'Cubo Gelatinoso', type: 'Limo', challengeRating: '2', armorClass: 6, hpMax: 63, initiativeBonus: -4),
  MonsterTemplate(name: 'Gosma Ocre', type: 'Limo', challengeRating: '2', armorClass: 8, hpMax: 52, initiativeBonus: -2),
  MonsterTemplate(name: 'Pudim Negro', type: 'Limo', challengeRating: '4', armorClass: 7, hpMax: 68, initiativeBonus: -3),
  MonsterTemplate(name: 'Espectador', type: 'Aberração', challengeRating: '3', armorClass: 14, hpMax: 45, initiativeBonus: 2),
  MonsterTemplate(name: 'Devorador de Mentes (Illithid)', type: 'Aberração', challengeRating: '7', armorClass: 15, hpMax: 99, initiativeBonus: 4),
  MonsterTemplate(name: 'Abolete', type: 'Aberração', challengeRating: '10', armorClass: 17, hpMax: 150, initiativeBonus: 7),
  MonsterTemplate(name: 'Observador (Beholder)', type: 'Aberração', challengeRating: '13', armorClass: 18, hpMax: 190, initiativeBonus: 12),

  // Constructos & Elementais (D&D 5.5e)
  MonsterTemplate(name: 'Espada Voadora', type: 'Constructo', challengeRating: '1/4', armorClass: 17, hpMax: 14, initiativeBonus: 4),
  MonsterTemplate(name: 'Armadura Animada', type: 'Constructo', challengeRating: '1', armorClass: 18, hpMax: 33, initiativeBonus: 0),
  MonsterTemplate(name: 'Gárgula', type: 'Elemental', challengeRating: '2', armorClass: 15, hpMax: 67, initiativeBonus: 0),
  MonsterTemplate(name: 'Elemental do Ar', type: 'Elemental', challengeRating: '5', armorClass: 15, hpMax: 90, initiativeBonus: 5),
  MonsterTemplate(name: 'Elemental da Terra', type: 'Elemental', challengeRating: '5', armorClass: 17, hpMax: 147, initiativeBonus: -1),
  MonsterTemplate(name: 'Elemental do Fogo', type: 'Elemental', challengeRating: '5', armorClass: 13, hpMax: 93, initiativeBonus: 3),
  MonsterTemplate(name: 'Elemental da Água', type: 'Elemental', challengeRating: '5', armorClass: 14, hpMax: 114, initiativeBonus: 2),
  MonsterTemplate(name: 'Golem de Carne', type: 'Constructo', challengeRating: '5', armorClass: 9, hpMax: 127, initiativeBonus: -1),
  MonsterTemplate(name: 'Golem de Argila', type: 'Constructo', challengeRating: '9', armorClass: 14, hpMax: 123, initiativeBonus: -1),
  MonsterTemplate(name: 'Golem de Pedra', type: 'Constructo', challengeRating: '10', armorClass: 18, hpMax: 220, initiativeBonus: -1),
  MonsterTemplate(name: 'Golem de Ferro', type: 'Constructo', challengeRating: '16', armorClass: 20, hpMax: 252, initiativeBonus: 9),
];

const List<MonsterTemplate> npcPresets = [
  MonsterTemplate(name: 'Plebeu', type: 'Aliado / Neutro', challengeRating: '0', armorClass: 10, hpMax: 4, initiativeBonus: 0),
  MonsterTemplate(name: 'Guarda da Cidade', type: 'Guarda', challengeRating: '1/8', armorClass: 16, hpMax: 11, initiativeBonus: 1),
  MonsterTemplate(name: 'Nobre', type: 'Nobre', challengeRating: '1/8', armorClass: 15, hpMax: 9, initiativeBonus: 1),
  MonsterTemplate(name: 'Mercador', type: 'Comerciante', challengeRating: '0', armorClass: 11, hpMax: 9, initiativeBonus: 0),
  MonsterTemplate(name: 'Sacerdote Acólito', type: 'Religioso', challengeRating: '1/4', armorClass: 13, hpMax: 11, initiativeBonus: 0),
  MonsterTemplate(name: 'Batedor Guia', type: 'Explorador', challengeRating: '1/2', armorClass: 13, hpMax: 16, initiativeBonus: 2),
  MonsterTemplate(name: 'Guerreiro Veterano', type: 'Combatente', challengeRating: '3', armorClass: 17, hpMax: 65, initiativeBonus: 3),
  MonsterTemplate(name: 'Cavaleiro Aliado', type: 'Cavaleiro', challengeRating: '3', armorClass: 18, hpMax: 52, initiativeBonus: 0),
  MonsterTemplate(name: 'Mago Aliado', type: 'Arcano', challengeRating: '6', armorClass: 15, hpMax: 81, initiativeBonus: 2),
];
