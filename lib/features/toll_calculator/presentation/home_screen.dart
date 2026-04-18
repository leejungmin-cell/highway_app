import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/toll_calculation_result.dart';
import '../domain/toll_calculator.dart';

enum _ScreenState { input, loading, result }

enum _IcTarget { departure, arrival }

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.calculator, super.key});

  final TollCalculator calculator;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _icList = [
    '가산',
    '강릉',
    '거제',
    '계룡',
    '고성',
    '공주',
    '광명',
    '광주',
    '괴산',
    '구리',
    '구미',
    '군산',
    '군포',
    '김제',
    '김천',
    '김포',
    '김해',
    '남구미',
    '남대구',
    '남대전',
    '남안성',
    '남여주',
    '남양주',
    '논산',
    '담양',
    '대전',
    '동대구',
    '동해',
    '마산',
    '목포',
    '물금',
    '부산',
    '부천',
    '북대구',
    '북여주',
    '사천',
    '서광주',
    '서대구',
    '서대전',
    '서인천',
    '서청주',
    '서평택',
    '선산',
    '성남',
    '속초',
    '송탄',
    '수원',
    '순천',
    '시흥',
    '신탄진',
    '안산',
    '안성',
    '안양',
    '양산',
    '여수',
    '여주',
    '영천',
    '오산',
    '옥천',
    '왜관',
    '용인',
    '원주',
    '유성',
    '이천',
    '익산',
    '인산',
    '인천',
    '인천공항',
    '전주',
    '진주',
    '창원',
    '천안',
    '춘천',
    '칠곡',
    '통영',
    '판교',
    '평택',
    '포항',
    '하남',
    '홍천',
    '횡성',
  ];

  _ScreenState _screenState = _ScreenState.input;
  _IcTarget? _sheetTarget;
  DateTime _selectedEntryTime = DateTime.now();
  String _departureIc = '';
  String _arrivalIc = '';
  TollCalculationResult? _result;
  int? _selectedDiscount;
  String? _toastMessage;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _setNow();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  void _setNow() {
    setState(() {
      _selectedEntryTime = DateTime.now();
    });
  }

  void _pickIc(String ic) {
    setState(() {
      if (_sheetTarget == _IcTarget.departure) {
        _departureIc = ic;
      } else {
        _arrivalIc = ic;
      }
      _sheetTarget = null;
    });
  }

  void _clearIc(_IcTarget target) {
    setState(() {
      if (target == _IcTarget.departure) {
        _departureIc = '';
      } else {
        _arrivalIc = '';
      }
    });
  }

  void _swapIc() {
    setState(() {
      final previousDeparture = _departureIc;
      _departureIc = _arrivalIc;
      _arrivalIc = previousDeparture;
    });
  }

  void _showToast(String message) {
    _toastTimer?.cancel();
    setState(() {
      _toastMessage = message;
    });
    _toastTimer = Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _toastMessage = null;
      });
    });
  }

  void _calculateExitTimes() {
    if (_departureIc.isEmpty || _arrivalIc.isEmpty) {
      _showToast('출발/도착 IC를 선택해주세요.');
      return;
    }

    setState(() {
      _screenState = _ScreenState.loading;
      _selectedDiscount = null;
    });

    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _result = widget.calculator.calculate(_selectedEntryTime);
        _screenState = _ScreenState.result;
      });
    });
  }

  void _resetCalculation() {
    setState(() {
      _screenState = _ScreenState.input;
      _result = null;
      _selectedDiscount = null;
    });
  }

  void _selectDiscount(int discount) {
    final result = _result;
    if (result == null) {
      return;
    }

    final window = discount == 50 ? result.fiftyPercent : result.thirtyPercent;
    if (!window.isAchievable) {
      _showToast('이 할인은 달성이 불가능해요');
      return;
    }

    final isSelected = _selectedDiscount == discount;
    setState(() {
      _selectedDiscount = isSelected ? null : discount;
    });

    if (isSelected) {
      _showToast('$discount% 알림을 해제했어요');
    } else {
      _showToast('30분 전 알림 예약 UI만 반영했습니다');
    }
  }

  String _formatTime(DateTime dateTime) {
    final period = dateTime.hour < 12 ? '오전' : '오후';
    final normalizedHour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final paddedHour = normalizedHour.toString().padLeft(2, '0');
    final paddedMinute = dateTime.minute.toString().padLeft(2, '0');
    return '$period $paddedHour:$paddedMinute';
  }

  String _formatCompactTime(DateTime dateTime) {
    final normalizedHour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final paddedHour = normalizedHour.toString().padLeft(2, '0');
    final paddedMinute = dateTime.minute.toString().padLeft(2, '0');
    return '$paddedHour:$paddedMinute';
  }

  String _periodLabel(DateTime dateTime) {
    return dateTime.hour < 12 ? '오전' : '오후';
  }

  String _dayLabel(DateTime target) {
    final entryDate = DateTime(
      _selectedEntryTime.year,
      _selectedEntryTime.month,
      _selectedEntryTime.day,
    );
    final targetDate = DateTime(target.year, target.month, target.day);
    final difference = targetDate.difference(entryDate).inDays;

    if (difference == 0) {
      return '오늘';
    }
    if (difference == 1) {
      return '내일';
    }
    return '$difference일 후';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 412),
                child: Container(
                  color: const Color(0xFFF9FAFB),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          _buildHeader(),
                          Expanded(child: _buildCurrentScreen()),
                        ],
                      ),
                      IgnorePointer(
                        child: Opacity(
                          opacity: 0,
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.all(1),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [Text('고속 통행료 할인 계산기'), Text('IC 선택')],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_sheetTarget != null) _buildOverlay(),
            if (_toastMessage != null) _buildToast(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF003898),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: const Text(
        '고속 통행료 할인받고 똑똑하게 운전하기',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_screenState) {
      case _ScreenState.input:
        return _buildInputScreen();
      case _ScreenState.loading:
        return _buildLoadingScreen();
      case _ScreenState.result:
        return _buildResultScreen();
    }
  }

  Widget _buildInputScreen() {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          children: [
            _buildIcSection(),
            const SizedBox(height: 20),
            _buildTimeSection(),
            const SizedBox(height: 20),
            _buildCalculateButton(),
            const SizedBox(height: 20),
            _buildInfoBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                '출발 IC',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF393C3C),
                ),
              ),
            ),
            SizedBox(width: 52),
            Expanded(
              child: Text(
                '도착 IC',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF393C3C),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _buildIcField(
                value: _departureIc,
                placeholder: '출발',
                onTap: () => setState(() => _sheetTarget = _IcTarget.departure),
                onClear: () => _clearIc(_IcTarget.departure),
              ),
            ),
            const SizedBox(width: 16),
            _buildSwapButton(),
            const SizedBox(width: 16),
            Expanded(
              child: _buildIcField(
                value: _arrivalIc,
                placeholder: '도착',
                onTap: () => setState(() => _sheetTarget = _IcTarget.arrival),
                onClear: () => _clearIc(_IcTarget.arrival),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIcField({
    required String value,
    required String placeholder,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final hasValue = value.isNotEmpty;
    return Material(
      color: const Color(0xFFF5F5F7),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD1D1D6), width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasValue ? value : placeholder,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: hasValue
                        ? const Color(0xFF393C3C)
                        : const Color(0xFF777777),
                  ),
                ),
              ),
              if (hasValue)
                GestureDetector(
                  onTap: onClear,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      '×',
                      style: TextStyle(fontSize: 18, color: Color(0xFFBBBBBB)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwapButton() {
    return GestureDetector(
      onTap: _swapIc,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF003898), width: 1.5),
        ),
        child: const Icon(
          Icons.swap_horiz_rounded,
          color: Color(0xFF003898),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '입차 시간',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF393C3C),
          ),
        ),
        const SizedBox(height: 11),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD1D1D6), width: 1.5),
          ),
          child: Row(
            children: [
              Text(
                _periodLabel(_selectedEntryTime),
                style: const TextStyle(fontSize: 18, color: Color(0xFF777777)),
              ),
              const SizedBox(width: 12),
              Text(
                _formatCompactTime(_selectedEntryTime),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF393C3C),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTimeDropdown<String>(
                value: _periodLabel(_selectedEntryTime),
                items: const ['오전', '오후'],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  final currentHour = _selectedEntryTime.hour;
                  final currentMinute = _selectedEntryTime.minute;
                  final currentHour12 = currentHour % 12 == 0
                      ? 12
                      : currentHour % 12;
                  final nextHour = value == '오전'
                      ? (currentHour12 == 12 ? 0 : currentHour12)
                      : (currentHour12 == 12 ? 12 : currentHour12 + 12);
                  setState(() {
                    _selectedEntryTime = DateTime(
                      _selectedEntryTime.year,
                      _selectedEntryTime.month,
                      _selectedEntryTime.day,
                      nextHour,
                      currentMinute,
                    );
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTimeDropdown<int>(
                value: _selectedEntryTime.hour % 12 == 0
                    ? 12
                    : _selectedEntryTime.hour % 12,
                items: List<int>.generate(12, (index) => index + 1),
                labelBuilder: (value) => '${value.toString().padLeft(2, '0')}시',
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  final period = _periodLabel(_selectedEntryTime);
                  final nextHour = period == '오전'
                      ? (value == 12 ? 0 : value)
                      : (value == 12 ? 12 : value + 12);
                  setState(() {
                    _selectedEntryTime = DateTime(
                      _selectedEntryTime.year,
                      _selectedEntryTime.month,
                      _selectedEntryTime.day,
                      nextHour,
                      _selectedEntryTime.minute,
                    );
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTimeDropdown<int>(
                value: _selectedEntryTime.minute,
                items: List<int>.generate(60, (index) => index),
                labelBuilder: (value) => '${value.toString().padLeft(2, '0')}분',
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedEntryTime = DateTime(
                      _selectedEntryTime.year,
                      _selectedEntryTime.month,
                      _selectedEntryTime.day,
                      _selectedEntryTime.hour,
                      value,
                    );
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _setNow,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF888787),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            ),
            child: const Text(
              '현재 시간으로 설정',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T value)? labelBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD1D1D6), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          alignment: Alignment.center,
          borderRadius: BorderRadius.circular(12),
          icon: const SizedBox.shrink(),
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15,
            color: Color(0xFF393C3C),
          ),
          selectedItemBuilder: (context) {
            return items.map((item) {
              return Center(
                child: Text(
                  labelBuilder?.call(item) ?? item.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF393C3C),
                  ),
                ),
              );
            }).toList();
          },
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Center(
                child: Text(labelBuilder?.call(item) ?? item.toString()),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _calculateExitTimes,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF003898),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF003898)),
          ),
        ),
        child: const Text(
          '출차 시간 계산하기',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D1D6)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '⚠',
                style: TextStyle(fontSize: 16, color: Color(0xFFF5A623)),
              ),
              SizedBox(width: 4),
              Text(
                '할인 정보',
                style: TextStyle(fontSize: 16, color: Color(0xFF777777)),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            '• 50% 할인: 심야 비율 70% 이상 (23:00~05:00 기준)',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6E6E73),
              height: 1.6,
            ),
          ),
          Text(
            '• 30% 할인: 심야 비율 20% 이상 70% 미만',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6E6E73),
              height: 1.6,
            ),
          ),
          Text(
            '• 심야 입차 시 빨리 나올수록 유리',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6E6E73),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: SizedBox(
        width: 46,
        height: 46,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Color(0xFF003898),
          backgroundColor: Color(0xFFE8E8E8),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final result = _result!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          _buildEntryCard(),
          const SizedBox(height: 16),
          _buildDiscountSection(
            discount: 50,
            title: '50% 할인',
            headerColor: const Color(0xFF155DFC),
            accentColor: const Color(0xFF155DFC),
            window: result.fiftyPercent,
          ),
          const SizedBox(height: 16),
          _buildDiscountSection(
            discount: 30,
            title: '30% 할인',
            headerColor: const Color(0xFF00A63E),
            accentColor: const Color(0xFF00A63E),
            window: result.thirtyPercent,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _resetCalculation,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF364153),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '다시 계산하기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.667),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '입차 시간',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4A5565),
              letterSpacing: -0.31,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(_selectedEntryTime),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
              letterSpacing: 0.37,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection({
    required int discount,
    required String title,
    required Color headerColor,
    required Color accentColor,
    required DiscountWindow window,
  }) {
    final isSelected = _selectedDiscount == discount;

    return GestureDetector(
      onTap: () => _selectDiscount(discount),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: accentColor, blurRadius: 0, spreadRadius: 3),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: headerColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.45,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isSelected
                                ? '✅ 최대 출차 30분 전 알림 예약됨'
                                : '탭하면 최대 출차 30분 전 알림 설정',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(255, 255, 255, 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      isSelected ? '🔕' : '🔔',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    left: BorderSide(color: accentColor, width: 1.667),
                    right: BorderSide(color: accentColor, width: 1.667),
                    bottom: BorderSide(color: accentColor, width: 1.667),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: window.isAchievable
                    ? Column(
                        children: [
                          _buildTimeRow(
                            label: '시작 시간',
                            dateTime: window.minimumExitTime!,
                            accentColor: accentColor,
                            showDivider: true,
                          ),
                          _buildTimeRow(
                            label: '종료 시간',
                            dateTime: window.maximumExitTime!,
                            accentColor: accentColor,
                            showDivider: false,
                          ),
                        ],
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '이 입차 시간으로는 달성 불가능해요',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB05A00),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow({
    required String label,
    required DateTime dateTime,
    required Color accentColor,
    required bool showDivider,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: showDivider ? 14 : 0),
      margin: EdgeInsets.only(bottom: showDivider ? 14 : 0),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.667),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4A5565),
              letterSpacing: -0.31,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(dateTime),
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: 0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _dayLabel(dateTime),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6A7282),
              letterSpacing: -0.15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    final target = _sheetTarget!;
    final selectedIc = target == _IcTarget.departure
        ? _departureIc
        : _arrivalIc;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _sheetTarget = null),
        child: Container(
          color: const Color.fromRGBO(0, 0, 0, 0.4),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 412,
                  maxHeight: 560,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 4,
                      margin: const EdgeInsets.fromLTRB(0, 13, 0, 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF0F0F0)),
                        ),
                      ),
                      child: Text(
                        target == _IcTarget.departure ? '출발 IC 선택' : '도착 IC 선택',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: _icList.length,
                        itemBuilder: (context, index) {
                          final ic = _icList[index];
                          final isSelected = ic == selectedIc;
                          return InkWell(
                            onTap: () => _pickIc(ic),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF0F4FF)
                                    : Colors.white,
                                border: const Border(
                                  bottom: BorderSide(color: Color(0xFFF2F2F2)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ic,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? const Color(0xFF003898)
                                            : const Color(0xFF111111),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Text(
                                      '✓',
                                      style: TextStyle(
                                        color: Color(0xFF003898),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToast() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _toastMessage!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
