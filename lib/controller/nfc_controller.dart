// ignore_for_file: avoid_print, constant_identifier_names

import 'dart:async';

import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:quickalert/quickalert.dart';

enum TagType { ISO_DEP, NFCF, MIFARE_CLASSIC }

class nfcController extends GetxController {
  RxBool isLoading = true.obs;
  // rest api response variable

  RxMap attendantData = {}.obs;

  // end of rest api response variable

  RxString identifier = "".obs;
  StreamSubscription<NfcTag>? _tagSubscription;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    tagRead();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void tagRead() {
    _tagSubscription?.cancel();
    NfcManager.instance.startSession(onDiscovered: _onTagDiscovered);
  }

  Future<void> _onTagDiscovered(NfcTag tag) async {
    String message = '';
    String identifierValue = '';

    if (tag.data.containsKey('isodep')) {
      message = _getMessageForTagType(TagType.ISO_DEP);
      identifierValue = _getIdentifierValue(
        tag.data['isodep']['identifier'],
      );
    } else if (tag.data.containsKey('nfcf')) {
      message = _getMessageForTagType(TagType.NFCF);
      identifierValue = _getIdentifierValue(
        tag.data['nfcf']['identifier'],
      );
    } else if (tag.data.containsKey('mifareclassic')) {
      message = _getMessageForTagType(TagType.MIFARE_CLASSIC);
      identifierValue = _getIdentifierValue(
        tag.data['mifareclassic']['identifier'],
      );
    } else {
      message = 'Kartu tidak dikenali';
    }

    identifier.value = identifierValue;
    print(identifierValue);

    _startTimer();
  }

  String _getMessageForTagType(TagType type) {
    switch (type) {
      case TagType.ISO_DEP:
        return 'Kartu isodep';
      case TagType.NFCF:
        return 'Kartu nfcf';
      case TagType.MIFARE_CLASSIC:
        return 'Kartu mifareclassic';
      default:
        return 'Kartu tidak dikenali';
    }
  }

  String _getIdentifierValue(List<int> identifier) {
    return identifier
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join('')
        .toUpperCase();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      identifier.value = "";
    });
  }

  //read data from api

  String formatDateAndTime(String dateTimeString) {
    // Parse string ke objek DateTime
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Format tanggal dan waktu menjadi string yang diinginkan
    String formattedDateTime =
        '${_formatDate(dateTime)}\n${_formatTime(dateTime)}';

    return formattedDateTime;
  }

  String _formatDate(DateTime dateTime) {
    // Format tanggal menjadi 'dd/MM/yyyy'
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = dateTime.hour < 12 ? 'AM' : 'PM';

    // Ubah jam ke format 12 jam jika diperlukan
    int hour12 = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    hour = hour12.toString().padLeft(2, '0');

    return '$hour:$minute $period';
  }
}
