
class AppData {
  static final List<Map<String, dynamic>> modules = [
    {
      "id": "segnaletica",
      "title": "Segnaletica Stradale",
      "description": "Padroneggia tutti i segnali, dai più comuni ai più specifici.",
      "icon": "traffic_light",
      "difficulty": "Principiante",
      "color": 0xFF4A90E2,
      "lessons": [
        {"id": "segnali_pericolo", "title": "Segnali di Pericolo", "questionIds": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]},
        {"id": "segnali_divieto", "title": "Segnali di Divieto", "questionIds": [16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]},
        {"id": "segnali_obbligo", "title": "Segnali di Obbligo", "questionIds": [31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45]},
        {"id": "segnali_indicazione", "title": "Segnali di Indicazione", "questionIds": [46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60]}
      ]
    },
    {
      "id": "norme_comportamento",
      "title": "Norme di Comportamento",
      "description": "Regole essenziali per una guida sicura e responsabile.",
      "icon": "rule",
      "difficulty": "Intermedio",
      "unlockRequirement": "Completa il modulo Segnaletica Stradale",
      "color": 0xFFD0021B,
      "lessons": [
        {"id": "limiti_distanza", "title": "Velocità e Distanza", "questionIds": [61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75]},
        {"id": "precedenza_incroci", "title": "Precedenza e Incroci", "questionIds": [76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90]}
      ]
    },
    {
      "id": "guida_sicura",
      "title": "Guida Sicura e Altre Norme",
      "description": "Approfondimenti su sicurezza, emergenze e casi particolari.",
      "icon": "health_and_safety",
      "difficulty": "Avanzato",
      "unlockRequirement": "Completa il modulo Norme di Comportamento",
      "color": 0xFFF5A623,
      "lessons": [
        {"id": "luci_documenti", "title": "Luci, Dispositivi e Documenti", "questionIds": [91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105]},
        {"id": "emergenze_comportamento", "title": "Emergenze e Responsabilità", "questionIds": [106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120]}
      ]
    }
  ];

  static Map<String, dynamic> getModuleById(String id) {
    return modules.firstWhere((module) => module['id'] == id, orElse: () => {});
  }

  static List<Map<String, dynamic>> getLessonsForModule(String moduleId) {
    final module = getModuleById(moduleId);
    if (module.isNotEmpty) {
      return (module['lessons'] as List<dynamic>).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
