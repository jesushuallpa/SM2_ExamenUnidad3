// screens/preference_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:proyecto_moviles_2/models/preference_questions.dart';
import 'package:proyecto_moviles_2/screens/PreferenceService.dart';
import 'package:proyecto_moviles_2/screens/main_screen.dart'; // <<<--- ASEGÚRATE DE ESTA IMPORTACIÓN

class PreferenceOnboardingScreen extends StatefulWidget {
  // ELIMINA ESTO: final VoidCallback onPreferencesSaved;
  const PreferenceOnboardingScreen({
    super.key,
  }); // <<<--- EL CONSTRUCTOR NO RECIBE EL CALLBACK

  @override
  State<PreferenceOnboardingScreen> createState() =>
      _PreferenceOnboardingScreenState();
}

class _PreferenceOnboardingScreenState
    extends State<PreferenceOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<String, dynamic> _selectedPreferences = {};

  @override
  void initState() {
    super.initState();
    for (var question in preferenceQuestions) {
      if (question.allowMultipleSelection) {
        _selectedPreferences[question.key] = <String>[];
      }
    }
  }

  void _handleOptionTap(PreferenceQuestion question, String option) {
    setState(() {
      if (question.allowMultipleSelection) {
        List<String> currentSelections = List<String>.from(
          _selectedPreferences[question.key] as List<dynamic>? ?? [],
        );
        if (currentSelections.contains(option)) {
          currentSelections.remove(option);
        } else {
          currentSelections.add(option);
        }
        _selectedPreferences[question.key] = currentSelections;
      } else {
        _selectedPreferences[question.key] = option;
      }
    });
  }

  void _nextPage() {
    final currentQuestion = preferenceQuestions[_currentPage];
    if (currentQuestion.allowMultipleSelection) {
      if ((_selectedPreferences[currentQuestion.key] as List<String>).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Por favor, selecciona al menos una opción para continuar.',
            ),
          ),
        );
        return;
      }
    } else {
      if (_selectedPreferences[currentQuestion.key] == null ||
          (_selectedPreferences[currentQuestion.key] as String).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona una opción para continuar.'),
          ),
        );
        return;
      }
    }

    if (_currentPage < preferenceQuestions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      setState(() {
        _currentPage++;
      });
    } else {
      _savePreferences(); // Llamada al método que guarda y navega
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  Future<void> _savePreferences() async {
    // Validar que todas las preguntas tienen una respuesta
    for (var question in preferenceQuestions) {
      if (question.allowMultipleSelection) {
        if (!(_selectedPreferences.containsKey(question.key) &&
            (_selectedPreferences[question.key] as List<String>).isNotEmpty)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Por favor, completa todas las preguntas. Falta: "${question.question}"',
                ),
              ),
            );
          }
          return;
        }
      } else {
        if (!(_selectedPreferences.containsKey(question.key) &&
            _selectedPreferences[question.key] != null &&
            (_selectedPreferences[question.key] as String).isNotEmpty)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Por favor, completa todas las preguntas. Falta: "${question.question}"',
                ),
              ),
            );
          }
          return;
        }
      }
    }

    try {
      await PreferenceService().updatePreferences(_selectedPreferences);

      // --- CAMBIO CLAVE AQUÍ: MUESTRA SNACKBAR Y NAVEGA DIRECTAMENTE ---
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferencias guardadas con éxito. ¡Disfruta!'),
          ),
        );
        // Opcional: un pequeño retraso para que el SnackBar sea visible
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // La navegación final la maneja esta misma pantalla
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar preferencias: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuéntanos sobre tus preferencias'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: preferenceQuestions.length,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final question = preferenceQuestions[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pregunta ${index + 1}/${preferenceQuestions.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            question.options.map((option) {
                              bool isSelected;
                              if (question.allowMultipleSelection) {
                                isSelected = (_selectedPreferences[question.key]
                                        as List<String>)
                                    .contains(option);
                              } else {
                                isSelected =
                                    (_selectedPreferences[question.key] ==
                                        option);
                              }

                              return ChoiceChip(
                                label: Text(option),
                                selected: isSelected,
                                onSelected: (selected) {
                                  _handleOptionTap(question, option);
                                },
                                selectedColor: Colors.purple.shade100,
                                backgroundColor: Colors.grey.shade200,
                                labelStyle: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.purple
                                          : Colors.black87,
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  OutlinedButton(
                    onPressed: _previousPage,
                    child: const Text('Anterior'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _currentPage == preferenceQuestions.length - 1
                        ? 'Finalizar'
                        : 'Siguiente',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
