import 'package:flutter/material.dart';

enum ConditionCategory {
  standard, // Condições oficiais D&D 5.5e
  classEffect, // Condições e estados ativados por classes / magias / maestrias
}

class DndConditionInfo {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final ConditionCategory category;
  final List<String> relatedClasses; // Classes que costumam ativar ou usar

  const DndConditionInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.category = ConditionCategory.standard,
    this.relatedClasses = const [],
  });
}

/// Condições Oficiais do D&D 5.5e (2024) + Condições/Estados Ativados por Classes
const List<DndConditionInfo> dndConditions = [
  // ===========================================================================
  // CONDIÇÕES GERAIS OFICIAIS D&D 5.5e
  // ===========================================================================
  DndConditionInfo(
    name: 'Concentração',
    description: 'Mantendo magia ativa (teste de CON ao sofrer dano)',
    icon: Icons.psychology,
    color: Color(0xFF64B5F6),
    category: ConditionCategory.standard,
    relatedClasses: [
      'Bardo',
      'Bruxo',
      'Clérigo',
      'Druida',
      'Feiticeiro',
      'Guardião (Patrulheiro)',
      'Mago',
      'Paladino',
    ],
  ),
  DndConditionInfo(
    name: 'Agarrado',
    description: 'Deslocamento 0; desvantagem para atacar quem não o agarrou',
    icon: Icons.pan_tool,
    color: Color(0xFFFFB74D),
    category: ConditionCategory.standard,
    relatedClasses: ['Bárbaro', 'Guerreiro', 'Monge'],
  ),
  DndConditionInfo(
    name: 'Amedrontado',
    description: 'Desvantagem em testes/ataques enquanto vir a fonte do medo',
    icon: Icons.sentiment_very_dissatisfied,
    color: Color(0xFFBA68C8),
    category: ConditionCategory.standard,
    relatedClasses: ['Bárbaro', 'Bruxo', 'Paladino', 'Bardo'],
  ),
  DndConditionInfo(
    name: 'Atordoado',
    description: 'Incapacitado, falha em FOR/DES, ataques contra têm vantagem',
    icon: Icons.stars,
    color: Color(0xFFFFD54F),
    category: ConditionCategory.standard,
    relatedClasses: ['Monge'],
  ),
  DndConditionInfo(
    name: 'Caído',
    description: 'Desvantagem nos ataques; ataques corpo a corpo contra têm vantagem',
    icon: Icons.trending_down,
    color: Color(0xFFA1887F),
    category: ConditionCategory.standard,
    relatedClasses: ['Bárbaro', 'Guerreiro', 'Monge', 'Druida'],
  ),
  DndConditionInfo(
    name: 'Cego',
    description: 'Falha em visão; ataques contra têm vantagem, seus têm desvantagem',
    icon: Icons.visibility_off,
    color: Color(0xFF90A4AE),
    category: ConditionCategory.standard,
    relatedClasses: ['Bardo', 'Clérigo', 'Feiticeiro', 'Mago', 'Ladino'],
  ),
  DndConditionInfo(
    name: 'Enfeitiçado',
    description: 'Não pode atacar quem o enfeitiçou; vantagem social para o encantador',
    icon: Icons.favorite,
    color: Color(0xFFF06292),
    category: ConditionCategory.standard,
    relatedClasses: ['Bardo', 'Bruxo', 'Feiticeiro', 'Mago', 'Druida'],
  ),
  DndConditionInfo(
    name: 'Envenenado',
    description: 'Desvantagem nas jogadas de ataque e testes de atributo',
    icon: Icons.science,
    color: Color(0xFF81C784),
    category: ConditionCategory.standard,
    relatedClasses: ['Ladino', 'Druida', 'Feiticeiro'],
  ),
  DndConditionInfo(
    name: 'Exaustão',
    description: '-2 em testes/ataques/CD e -1,5m de deslocamento por nível (5.5e)',
    icon: Icons.battery_alert,
    color: Color(0xFFFF8A65),
    category: ConditionCategory.standard,
  ),
  DndConditionInfo(
    name: 'Impedido',
    description: 'Deslocamento 0; ataques contra têm vantagem, seus têm desvantagem',
    icon: Icons.link,
    color: Color(0xFFFFB74D),
    category: ConditionCategory.standard,
    relatedClasses: ['Druida', 'Guardião (Patrulheiro)', 'Mago'],
  ),
  DndConditionInfo(
    name: 'Incapacitado',
    description: 'Não pode realizar ações, ações bônus ou reações; perde concentração',
    icon: Icons.block,
    color: Color(0xFFEF5350),
    category: ConditionCategory.standard,
  ),
  DndConditionInfo(
    name: 'Inconsciente',
    description: 'Incapacitado e caído; ataques a 1,5m são acertos críticos',
    icon: Icons.bedtime,
    color: Color(0xFF9575CD),
    category: ConditionCategory.standard,
  ),
  DndConditionInfo(
    name: 'Invisível',
    description: 'Vantagem na iniciativa e nos ataques; ataques contra têm desvantagem',
    icon: Icons.blur_on,
    color: Color(0xFF4DD0E1),
    category: ConditionCategory.standard,
    relatedClasses: ['Bardo', 'Bruxo', 'Feiticeiro', 'Ladino', 'Mago', 'Guardião (Patrulheiro)'],
  ),
  DndConditionInfo(
    name: 'Paralisado',
    description: 'Incapacitado; falha em FOR/DES; acertos a 1,5m são críticos',
    icon: Icons.flash_off,
    color: Color(0xFFFFD54F),
    category: ConditionCategory.standard,
    relatedClasses: ['Bardo', 'Clérigo', 'Bruxo', 'Feiticeiro', 'Mago'],
  ),
  DndConditionInfo(
    name: 'Petrificado',
    description: 'Transformado em pedra; resistência a todo dano; incapacitado',
    icon: Icons.terrain,
    color: Color(0xFFBCAAA4),
    category: ConditionCategory.standard,
  ),
  DndConditionInfo(
    name: 'Surdo',
    description: 'Não pode ouvir e falha automaticamente em testes de audição',
    icon: Icons.hearing_disabled,
    color: Color(0xFF90A4AE),
    category: ConditionCategory.standard,
  ),

  // ===========================================================================
  // CONDIÇÕES E ESTADOS ATIVADOS POR CLASSES (D&D 5.5e)
  // ===========================================================================
  // Bárbaro
  DndConditionInfo(
    name: 'Em Fúria',
    description: 'Bárbaro: Resistência a dano físico, bônus de dano e vantagem em FOR',
    icon: Icons.fitness_center,
    color: Color(0xFFFF8A65),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Bárbaro'],
  ),
  DndConditionInfo(
    name: 'Ataque Descuidado',
    description: 'Bárbaro: Vantagem nos ataques, mas ataques contra você têm vantagem',
    icon: Icons.gavel,
    color: Color(0xFFFFAB91),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Bárbaro'],
  ),

  // Bardo
  DndConditionInfo(
    name: 'Inspirado (Bardo)',
    description: 'Bardo: Possui dado de Inspiração de Bardo para somar em teste/ataque/dano',
    icon: Icons.music_note,
    color: Color(0xFFF06292),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Bardo'],
  ),

  // Bruxo
  DndConditionInfo(
    name: 'Maldição (Bruxaria / Hex)',
    description: 'Bruxo: Alvo sofre +1d6 necrótico e desvantagem em testes de 1 atributo',
    icon: Icons.auto_fix_high,
    color: Color(0xFFB39DDB),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Bruxo'],
  ),
  DndConditionInfo(
    name: 'Forma Pavorosa',
    description: 'Bruxo: PV temporários, imune a Amedrontado e ataques causam medo',
    icon: Icons.nights_stay,
    color: Color(0xFF9575CD),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Bruxo'],
  ),

  // Clérigo & Paladino
  DndConditionInfo(
    name: 'Abençoado (Bless)',
    description: 'Clérigo/Paladino: +1d4 nas jogadas de ataque e salvaguardas',
    icon: Icons.wb_sunny,
    color: Color(0xFFFFD54F),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Clérigo', 'Paladino'],
  ),
  DndConditionInfo(
    name: 'Escudo da Fé',
    description: 'Clérigo/Paladino: +2 na Classe de Armadura (CA)',
    icon: Icons.security,
    color: Color(0xFFFFE082),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Clérigo', 'Paladino'],
  ),
  DndConditionInfo(
    name: 'Espíritos Guardiões',
    description: 'Clérigo: Aura de 4,5m que reduz deslocamento inimigo e causa dano',
    icon: Icons.blur_circular,
    color: Color(0xFFFFD54F),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Clérigo'],
  ),
  DndConditionInfo(
    name: 'Perdição (Bane)',
    description: 'Clérigo/Bardo: Alvo sofre -1d4 nas jogadas de ataque e salvaguardas',
    icon: Icons.trending_down,
    color: Color(0xFFEF9A9A),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Clérigo', 'Bardo'],
  ),
  DndConditionInfo(
    name: 'Aura de Proteção',
    description: 'Paladino: Bônus de Carisma em todas as salvaguardas',
    icon: Icons.verified_user,
    color: Color(0xFFFFE082),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Paladino'],
  ),
  DndConditionInfo(
    name: 'Duelo Compelido',
    description: 'Paladino: Alvo tem desvantagem para atacar outros que não o Paladino',
    icon: Icons.sports_kabaddi,
    color: Color(0xFFFFE082),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Paladino'],
  ),

  // Druida & Guardião (Patrulheiro)
  DndConditionInfo(
    name: 'Forma Selvagem',
    description: 'Druida: Transformado em fera com PV temporários e ataques naturais',
    icon: Icons.pets,
    color: Color(0xFF81C784),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Druida'],
  ),
  DndConditionInfo(
    name: 'Fogo das Fadas',
    description: 'Druida/Bardo: Alvo brilha; ataques contra ele têm vantagem',
    icon: Icons.flare,
    color: Color(0xFF81C784),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Druida', 'Bardo'],
  ),
  DndConditionInfo(
    name: 'Marca do Caçador',
    description: 'Guardião: Alvo marcado sofre +1d6 de dano de força nos ataques',
    icon: Icons.gps_fixed,
    color: Color(0xFFA5D6A7),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Guardião (Patrulheiro)'],
  ),

  // Feiticeiro & Mago
  DndConditionInfo(
    name: 'Feitiçaria Inata',
    description: 'Feiticeiro (5.5e): +1 na CD das magias e vantagem nos ataques mágicos',
    icon: Icons.bolt,
    color: Color(0xFFFFB74D),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Feiticeiro'],
  ),
  DndConditionInfo(
    name: 'Armadura Arcana',
    description: 'Mago/Feiticeiro: CA base se torna 13 + modificador de Destreza',
    icon: Icons.shield_outlined,
    color: Color(0xFF64B5F6),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Mago', 'Feiticeiro'],
  ),
  DndConditionInfo(
    name: 'Escudo Arcano (+5 CA)',
    description: 'Mago/Feiticeiro: +5 na CA até o início do próximo turno',
    icon: Icons.shield,
    color: Color(0xFF64B5F6),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Mago', 'Feiticeiro'],
  ),
  DndConditionInfo(
    name: 'Acelerado (Haste)',
    description: 'Mago/Feiticeiro: Deslocamento dobrado, +2 CA e ação extra',
    icon: Icons.fast_forward,
    color: Color(0xFF4DD0E1),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Mago', 'Feiticeiro'],
  ),
  DndConditionInfo(
    name: 'Lentidão (Slow)',
    description: 'Mago/Feiticeiro: Metade do deslocamento, -2 CA/DES e sem reações',
    icon: Icons.slow_motion_video,
    color: Color(0xFFEF9A9A),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Mago', 'Feiticeiro'],
  ),
  DndConditionInfo(
    name: 'Voando',
    description: 'Deslocamento de voo ativo',
    icon: Icons.air,
    color: Color(0xFF90CAF9),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Mago', 'Feiticeiro', 'Bruxo', 'Druida'],
  ),

  // Guerreiro, Ladino & Monge (+ Maestrias 5.5e)
  DndConditionInfo(
    name: 'Escondido (Furtivo)',
    description: 'Ladino: Invisível/oculto; vantagem no próximo ataque (Ataque Furtivo)',
    icon: Icons.visibility_off,
    color: Color(0xFF90A4AE),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Ladino', 'Guardião (Patrulheiro)', 'Monge'],
  ),
  DndConditionInfo(
    name: 'Esquiva (Defesa Paciente)',
    description: 'Monge/Geral: Ataques contra têm desvantagem; vantagem em DES',
    icon: Icons.self_improvement,
    color: Color(0xFF4DD0E1),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Monge', 'Guerreiro', 'Ladino'],
  ),
  DndConditionInfo(
    name: 'Vexado (Maestria Vex)',
    description: 'Maestria 5.5e: Próximo ataque contra este alvo tem vantagem',
    icon: Icons.ads_click,
    color: Color(0xFFBCAAA4),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Guerreiro', 'Ladino', 'Guardião (Patrulheiro)', 'Bárbaro'],
  ),
  DndConditionInfo(
    name: 'Atrapalhado (Maestria Sap)',
    description: 'Maestria 5.5e: Próximo ataque deste alvo tem desvantagem',
    icon: Icons.do_not_disturb_on,
    color: Color(0xFFBCAAA4),
    category: ConditionCategory.classEffect,
    relatedClasses: ['Guerreiro', 'Paladino', 'Bárbaro', 'Clérigo'],
  ),
];

DndConditionInfo? getDndConditionInfo(String name) {
  final normalized = name.trim().toLowerCase();
  for (final c in dndConditions) {
    if (c.name.toLowerCase() == normalized) {
      return c;
    }
  }
  return null;
}
