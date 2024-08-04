import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  final SupabaseClient client;

  SupabaseClientService._internal()
      : client = SupabaseClient(
          'https://zpnrhnnbetfdvnffcrmj.supabase.co',
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwbnJobm5iZXRmZHZuZmZjcm1qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE2MTUxMTcsImV4cCI6MjAzNzE5MTExN30.Dw3FMknFnLzuBeqJY7pTeCMCRwIoBl2ihyh_uXmRZJ8',
        );

  static SupabaseClientService? _instance;

  static SupabaseClientService getInstance() {
    if (_instance == null) {
      _instance = SupabaseClientService._internal();
    }
    return _instance!;
  }
}
