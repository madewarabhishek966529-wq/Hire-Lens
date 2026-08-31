import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../domain/entities/candidate_profile.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/hireability_score.dart';
import '../../domain/entities/skill_gap.dart';
import '../../domain/entities/evidence.dart';
import '../../domain/entities/resume_suggestion.dart';
import '../../domain/entities/interview.dart';
import '../../domain/entities/application.dart';
import 'demo_data_seeder.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hirelens.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // In web, sqflite fallback
      databaseFactory = databaseFactoryFfi;
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        data TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE jobs (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        company TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE hireability_scores (
        id TEXT PRIMARY KEY,
        jobId TEXT NOT NULL,
        overallScore INTEGER NOT NULL,
        data TEXT NOT NULL,
        calculatedAt TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE skill_gaps (
        id TEXT PRIMARY KEY,
        jobId TEXT NOT NULL,
        skillName TEXT NOT NULL,
        status TEXT NOT NULL,
        priority TEXT NOT NULL,
        data TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE evidence_items (
        id TEXT PRIMARY KEY,
        requirementId TEXT NOT NULL,
        confidence TEXT NOT NULL,
        data TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE resume_suggestions (
        id TEXT PRIMARY KEY,
        jobId TEXT NOT NULL,
        status TEXT NOT NULL,
        data TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE interview_sessions (
        id TEXT PRIMARY KEY,
        jobId TEXT NOT NULL,
        mode TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE applications (
        id TEXT PRIMARY KEY,
        jobId TEXT NOT NULL,
        stage TEXT NOT NULL,
        data TEXT NOT NULL,
        appliedDate TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE progress_snapshots (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        weekLabel TEXT NOT NULL,
        hireabilityScore INTEGER NOT NULL,
        data TEXT NOT NULL,
        timestamp TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE ai_observability_logs (
        id TEXT PRIMARY KEY,
        requestType TEXT NOT NULL,
        latencyMs INTEGER NOT NULL,
        tokensUsed INTEGER NOT NULL,
        costEstimate REAL NOT NULL,
        status TEXT NOT NULL,
        timestamp TEXT NOT NULL
      );
    ''');

    // Seed initial demo data
    await DemoDataSeeder.seedInitialData(db);
  }

  // --- CRUD METHODS ---

  // Candidate Profile
  Future<CandidateProfile?> getProfile(String userId) async {
    final db = await database;
    final maps = await db.query(
      'profiles',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return CandidateProfile.fromJson(jsonDecode(maps.first['data'] as String));
    }
    return null;
  }

  Future<void> saveProfile(CandidateProfile profile) async {
    final db = await database;
    await db.insert(
      'profiles',
      {
        'id': profile.id,
        'userId': profile.userId,
        'data': jsonEncode(profile.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Jobs
  Future<List<Job>> getJobs(String userId) async {
    final db = await database;
    final maps = await db.query(
      'jobs',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => Job.fromJson(jsonDecode(m['data'] as String))).toList();
  }

  Future<Job?> getJobById(String jobId) async {
    final db = await database;
    final maps = await db.query(
      'jobs',
      where: 'id = ?',
      whereArgs: [jobId],
    );
    if (maps.isNotEmpty) {
      return Job.fromJson(jsonDecode(maps.first['data'] as String));
    }
    return null;
  }

  Future<void> saveJob(Job job) async {
    final db = await database;
    await db.insert(
      'jobs',
      {
        'id': job.id,
        'userId': job.userId,
        'title': job.title,
        'company': job.company,
        'data': jsonEncode(job.toJson()),
        'createdAt': job.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Hireability Scores
  Future<HireabilityScore?> getHireabilityScore(String jobId) async {
    final db = await database;
    final maps = await db.query(
      'hireability_scores',
      where: 'jobId = ?',
      whereArgs: [jobId],
      orderBy: 'calculatedAt DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return HireabilityScore.fromJson(jsonDecode(maps.first['data'] as String));
    }
    return null;
  }

  Future<void> saveHireabilityScore(HireabilityScore score) async {
    final db = await database;
    await db.insert(
      'hireability_scores',
      {
        'id': score.id,
        'jobId': score.jobId,
        'overallScore': score.overallScore,
        'data': jsonEncode(score.toJson()),
        'calculatedAt': score.calculatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Skill Gaps
  Future<List<SkillGap>> getSkillGaps(String jobId) async {
    final db = await database;
    final maps = await db.query(
      'skill_gaps',
      where: 'jobId = ?',
      whereArgs: [jobId],
    );
    return maps.map((m) => SkillGap.fromJson(jsonDecode(m['data'] as String))).toList();
  }

  Future<void> saveSkillGaps(List<SkillGap> gaps) async {
    final db = await database;
    final batch = db.batch();
    for (final gap in gaps) {
      batch.insert(
        'skill_gaps',
        {
          'id': gap.id,
          'jobId': gap.jobId,
          'skillName': gap.skillName,
          'status': gap.status.name,
          'priority': gap.priority.name,
          'data': jsonEncode(gap.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Evidence
  Future<List<EvidenceItem>> getEvidenceForRequirements(List<String> reqIds) async {
    final db = await database;
    final maps = await db.query('evidence_items');
    return maps
        .map((m) => EvidenceItem.fromJson(jsonDecode(m['data'] as String)))
        .toList();
  }

  Future<void> saveEvidenceItems(List<EvidenceItem> items) async {
    final db = await database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert(
        'evidence_items',
        {
          'id': item.id,
          'requirementId': item.requirementId,
          'confidence': item.confidence.name,
          'data': jsonEncode(item.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Resume Suggestions
  Future<List<ResumeSuggestion>> getResumeSuggestions(String jobId) async {
    final db = await database;
    final maps = await db.query(
      'resume_suggestions',
      where: 'jobId = ?',
      whereArgs: [jobId],
    );
    return maps
        .map((m) => ResumeSuggestion.fromJson(jsonDecode(m['data'] as String)))
        .toList();
  }

  Future<void> updateResumeSuggestion(ResumeSuggestion suggestion) async {
    final db = await database;
    await db.insert(
      'resume_suggestions',
      {
        'id': suggestion.id,
        'jobId': suggestion.jobId,
        'status': suggestion.status.name,
        'data': jsonEncode(suggestion.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Interview Sessions
  Future<List<InterviewSession>> getInterviewSessions(String jobId) async {
    final db = await database;
    final maps = await db.query(
      'interview_sessions',
      where: 'jobId = ?',
      whereArgs: [jobId],
      orderBy: 'createdAt DESC',
    );
    return maps
        .map((m) => InterviewSession.fromJson(jsonDecode(m['data'] as String)))
        .toList();
  }

  Future<void> saveInterviewSession(InterviewSession session) async {
    final db = await database;
    await db.insert(
      'interview_sessions',
      {
        'id': session.id,
        'jobId': session.jobId,
        'mode': session.mode.name,
        'data': jsonEncode(session.toJson()),
        'createdAt': session.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Applications
  Future<List<ApplicationTrack>> getApplications() async {
    final db = await database;
    final maps = await db.query('applications', orderBy: 'appliedDate DESC');
    return maps
        .map((m) => ApplicationTrack.fromJson(jsonDecode(m['data'] as String)))
        .toList();
  }

  Future<void> saveApplication(ApplicationTrack app) async {
    final db = await database;
    await db.insert(
      'applications',
      {
        'id': app.id,
        'jobId': app.jobId,
        'stage': app.stage.name,
        'data': jsonEncode(app.toJson()),
        'appliedDate': app.appliedDate.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // AI Observability Logs
  Future<List<Map<String, dynamic>>> getObservabilityLogs() async {
    final db = await database;
    return await db.query('ai_observability_logs', orderBy: 'timestamp DESC', limit: 100);
  }

  Future<void> logAiRequest({
    required String requestType,
    required int latencyMs,
    required int tokensUsed,
    required double costEstimate,
    required String status,
  }) async {
    final db = await database;
    await db.insert('ai_observability_logs', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'requestType': requestType,
      'latencyMs': latencyMs,
      'tokensUsed': tokensUsed,
      'costEstimate': costEstimate,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
