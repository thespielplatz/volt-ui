bool validateBolt11(String? invoice) {
  if (invoice == null || invoice.isEmpty) return false;

  final lower = invoice.toLowerCase();

  // Valid BOLT11 prefixes
  const prefixes = ['lnbc', 'lntb', 'lnbcrt'];
  if (!prefixes.any((p) => lower.startsWith(p))) return false;

  // Check Bech32 format: should contain a '1' separator after prefix
  final sepIndex = lower.indexOf('1');
  if (sepIndex == -1 || sepIndex < 4) return false;

  // Check that all characters after the prefix are valid Bech32 chars
  final bech32Chars = RegExp(r'^[0123456789acdefghjklmnpqrstuvwxyz]+$');
  final dataPart = lower.substring(sepIndex + 1);
  if (!bech32Chars.hasMatch(dataPart)) return false;

  // Optional: length check (realistic upper bound)
  if (invoice.length > 500) return false;

  return true;
}
