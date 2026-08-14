import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:path_provider/path_provider.dart';

class SubmitTtdWidget extends StatefulWidget {
  const SubmitTtdWidget({
    Key? key,
    required this.onSubmit,
    this.primaryColor = const Color(0xff059669),
  }) : super(key: key);
  
  final Function(File) onSubmit;
  final Color primaryColor;

  @override
  State<SubmitTtdWidget> createState() => _SubmitTtdWidgetState();
}

class _SubmitTtdWidgetState extends State<SubmitTtdWidget> {
  GlobalKey<SignatureState> signKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tanda Tangan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff111827),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xffF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 18, color: Color(0xff6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Silakan gambar tanda tangan Anda di dalam area kotak di bawah ini.',
            style: TextStyle(fontSize: 12, color: Color(0xff6B7280)),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffE5E7EB), width: 1.5),
            ),
            height: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Signature(
                key: signKey,
                color: const Color(0xff111827),
                strokeWidth: 4.0,
                onSign: () {},
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff4B5563),
                    side: const BorderSide(color: Color(0xffE5E7EB)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => signKey.currentState!.clear(),
                  child: const Text('Hapus', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final sign = signKey.currentState!;
                    final image = await sign.getData();
                    var data = await image.toByteData(format: ImageByteFormat.png);
                    final dir = await getTemporaryDirectory();

                    if (data != null) {
                      final timestamp = DateTime.now().millisecondsSinceEpoch;
                      final file = File('${dir.path}/signature_$timestamp.png');
                      if (file.existsSync()) {
                        file.deleteSync();
                      }
                      file.writeAsBytesSync(data.buffer.asUint8List(), flush: true);
                      sign.clear();
                      widget.onSubmit(file);
                      Navigator.pop(context, file.path);
                    } else {
                      sign.clear();
                    }
                  },
                  child: const Text('Simpan Tanda Tangan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

