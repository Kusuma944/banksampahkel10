/// Entity domain untuk user yang sudah login lewat cloud auth
/// (Email atau Google Sign-In). Murni Dart, tidak tahu apa-apa
/// soal Supabase/Firebase di baliknya.
class AppUser {
  final String id;
  final String email;
  final String? namaLengkap;

  const AppUser({
    required this.id,
    required this.email,
    this.namaLengkap,
  });
}
