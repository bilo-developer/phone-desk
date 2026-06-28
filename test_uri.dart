void main() {
  try {
    print(Uri.parse('http://127.0.0.1:8080/screen/frame?displayId=MONITOR\\BOE0910\\{4d36e96e-e325-11ce-bfc1-08002be10318}\\0001'));
  } catch (e) {
    print('Error: $e');
  }
}
