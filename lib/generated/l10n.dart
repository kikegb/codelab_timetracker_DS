// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Fecha inicial: `
  String get initialDate {
    return Intl.message(
      'Fecha inicial: ',
      name: 'initialDate',
      desc: '',
      args: [],
    );
  }

  /// `Fecha de finalización: `
  String get finalDate {
    return Intl.message(
      'Fecha de finalización: ',
      name: 'finalDate',
      desc: '',
      args: [],
    );
  }

  /// `desde`
  String get from {
    return Intl.message(
      'desde',
      name: 'from',
      desc: '',
      args: [],
    );
  }

  /// `a`
  String get to {
    return Intl.message(
      'a',
      name: 'to',
      desc: '',
      args: [],
    );
  }

  /// `Actividad que no es ni proyecto ni tarea`
  String get unknownActivity {
    return Intl.message(
      'Actividad que no es ni proyecto ni tarea',
      name: 'unknownActivity',
      desc: '',
      args: [],
    );
  }

  /// `indefinido`
  String get undefined {
    return Intl.message(
      'indefinido',
      name: 'undefined',
      desc: '',
      args: [],
    );
  }

  /// `dd-MM-yyyy HH:mm:ss`
  String get dateFormat {
    return Intl.message(
      'dd-MM-yyyy HH:mm:ss',
      name: 'dateFormat',
      desc: '',
      args: [],
    );
  }

  /// `Resultados para: `
  String get resultsFor {
    return Intl.message(
      'Resultados para: ',
      name: 'resultsFor',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'intervalDate' key

  /// `Crear Proyecto`
  String get create_project {
    return Intl.message(
      'Crear Proyecto',
      name: 'create_project',
      desc: '',
      args: [],
    );
  }

  /// `Crear`
  String get create {
    return Intl.message(
      'Crear',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Introducir nombre del proyecto`
  String get Iproject {
    return Intl.message(
      'Introducir nombre del proyecto',
      name: 'Iproject',
      desc: '',
      args: [],
    );
  }

  /// `Nombre`
  String get Name {
    return Intl.message(
      'Nombre',
      name: 'Name',
      desc: '',
      args: [],
    );
  }

  /// `Introduce el nombre de la tarea`
  String get Itask {
    return Intl.message(
      'Introduce el nombre de la tarea',
      name: 'Itask',
      desc: '',
      args: [],
    );
  }

  /// `Crear Tarea`
  String get create_task {
    return Intl.message(
      'Crear Tarea',
      name: 'create_task',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
      Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
      Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
