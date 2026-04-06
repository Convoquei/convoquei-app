import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class PendingCard {
  final String index;
  final String tag;
  final String title;
  final String datetime;

  const PendingCard({
    required this.index,
    required this.tag,
    required this.title,
    required this.datetime,
  });
}

class NoticeItem {
  final String category;
  final String time;
  final String body;
  final String author;
  final String avatarUrl;
  final bool highlight;

  const NoticeItem({
    required this.category,
    required this.time,
    required this.body,
    required this.author,
    required this.avatarUrl,
    this.highlight = false,
  });
}

class MyScheduleItem {
  final String weekday;
  final int day;
  final String title;
  final String time;
  final String location;
  final String role;
  final bool isPrimary;

  const MyScheduleItem({
    required this.weekday,
    required this.day,
    required this.title,
    required this.time,
    required this.location,
    required this.role,
    this.isPrimary = false,
  });
}

class OrgEventItem {
  final String weekday;
  final int day;
  final String title;
  final String time;
  final String location;
  final bool isClosed;

  const OrgEventItem({
    required this.weekday,
    required this.day,
    required this.title,
    required this.time,
    required this.location,
    required this.isClosed,
  });
}

class BirthdayItem {
  final String name;
  final String date;
  final String avatarUrl;

  const BirthdayItem({
    required this.name,
    required this.date,
    required this.avatarUrl,
  });
}

// ── Page ─────────────────────────────────────────────────────────────────────

class OrgHomePage extends StatefulWidget {
  const OrgHomePage({super.key});

  @override
  State<OrgHomePage> createState() => _OrgHomePageState();
}

class _OrgHomePageState extends State<OrgHomePage> {
  final List<PendingCard> _pending = [
    const PendingCard(index: '1/10', tag: 'Urgente', title: 'Ensaio Geral', datetime: 'Encerra em 2h'),
    const PendingCard(index: '2/10', tag: 'Nova Escala', title: 'Culto de Domingo', datetime: 'Dom, 18:30 • Templo'),
    const PendingCard(index: '3/10', tag: 'Reunião', title: 'Reunião de Liderança', datetime: 'Seg, 20:00 • Sala 1'),
    const PendingCard(index: '4/10', tag: 'Escala', title: 'Culto de Jovens', datetime: 'Sáb, 19:30 • Auditório'),
    const PendingCard(index: '5/10', tag: 'Extra', title: 'Ensaio de Naipe (Vocal)', datetime: 'Qua, 19:00 • Sala 3'),
    const PendingCard(index: '6/10', tag: 'Especial', title: 'Santa Ceia', datetime: 'Dom, 18:30 • Templo'),
    const PendingCard(index: '7/10', tag: 'Escala', title: 'Culto de Ensino', datetime: 'Qui, 19:30 • Templo'),
    const PendingCard(index: '8/10', tag: 'Externo', title: 'Acampamento Jovem', datetime: 'Sex a Dom • Sítio'),
    const PendingCard(index: '9/10', tag: 'Especial', title: 'Vigília Geral', datetime: 'Sex, 23:00 • Templo'),
    const PendingCard(index: '10/10', tag: 'Voluntário', title: 'Mutirão de Limpeza', datetime: 'Sáb, 08:00 • Igreja'),
  ];

  final List<NoticeItem> _notices = [
    const NoticeItem(
      category: 'Aviso Importante',
      time: 'Hoje, 09:30',
      body: 'Atenção equipa de Mídia: o ensaio de sábado foi remarcado para as 15h devido à manutenção do projetor principal.',
      author: 'Ana Clara (Líder)',
      avatarUrl: 'https://i.pravatar.cc/100?img=33',
      highlight: true,
    ),
    const NoticeItem(
      category: 'Geral',
      time: 'Ontem',
      body: 'Lembro a todos que as camisas do ministério já chegaram. Por favor, retirem na secretaria após o culto.',
      author: 'Pr. Marcos Paulo',
      avatarUrl: 'https://i.pravatar.cc/100?img=60',
    ),
  ];

  final List<MyScheduleItem> _mySchedules = [
    const MyScheduleItem(
      weekday: 'Dom', day: 17,
      title: 'Culto de Domingo', time: '18:30', location: 'Templo',
      role: 'Vocal - Soprano', isPrimary: true,
    ),
    const MyScheduleItem(
      weekday: 'Qui', day: 21,
      title: 'Culto de Ensino', time: '19:30', location: 'Templo',
      role: 'Transmissão',
    ),
  ];

  final List<OrgEventItem> _orgEvents = [
    const OrgEventItem(weekday: 'Sáb', day: 16, title: 'Ensaio de Jovens', time: '15:00', location: 'Sala de Música', isClosed: true),
    const OrgEventItem(weekday: 'Dom', day: 17, title: 'Culto de Domingo', time: '18:30', location: 'Templo Principal', isClosed: false),
    const OrgEventItem(weekday: 'Seg', day: 18, title: 'Reunião de Liderança', time: '20:00', location: 'Sala 1', isClosed: false),
  ];

  final List<BirthdayItem> _birthdays = [
    const BirthdayItem(name: 'Roberto', date: '08/03', avatarUrl: 'https://i.pravatar.cc/100?img=5'),
    const BirthdayItem(name: 'Mariana', date: '12/03', avatarUrl: 'https://i.pravatar.cc/100?img=47'),
    const BirthdayItem(name: 'João', date: '24/03', avatarUrl: 'https://i.pravatar.cc/100?img=12'),
    const BirthdayItem(name: 'Ana', date: '29/03', avatarUrl: 'https://i.pravatar.cc/100?img=33'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 24),
            if (_pending.isNotEmpty) ...[
              _buildSectionHeader(
                'Aguardando Resposta',
                badge: '${_pending.length} Pendentes',
                badgeColor: AppTheme.secondaryColor,
              ),
              const SizedBox(height: 12),
              _SwipeCardStack(cards: _pending),
              const SizedBox(height: 24),
            ],
            _buildSectionHeader('Mural de Avisos'),
            const SizedBox(height: 12),
            _buildNotices(),
            const SizedBox(height: 24),
            _buildSectionHeader('As Minhas Escalas', actionLabel: 'Ver todas'),
            const SizedBox(height: 12),
            _buildMySchedules(),
            const SizedBox(height: 24),
            _buildSectionHeader('Eventos da Organização'),
            const SizedBox(height: 12),
            _buildOrgEvents(),
            const SizedBox(height: 24),
            _buildSectionHeader('🎉 Aniversariantes (Março)'),
            const SizedBox(height: 12),
            _buildBirthdays(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Olá, Lucas.', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Você tem '),
              TextSpan(
                text: '${_pending.length} pendências',
                style: const TextStyle(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
              ),
              const TextSpan(text: ' na equipa.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title,
      {String? badge, Color? badgeColor, String? actionLabel}) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 18)),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (badgeColor ?? AppTheme.primaryColor)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(badge,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor ?? AppTheme.primaryColor,
                    fontFamily: 'Inter',
                    letterSpacing: 0.6)),
          ),
        if (actionLabel != null)
          Text(actionLabel,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Inter')),
      ],
    );
  }

  Widget _buildNotices() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _notices.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final n = _notices[i];
          return Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: n.highlight ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: n.highlight
                      ? const Color(0xFFBFDBFE)
                      : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: n.highlight
                            ? const Color(0xFFDBEAFE)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(n.category,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: n.highlight
                                  ? AppTheme.primaryColor
                                  : const Color(0xFF64748B),
                              fontFamily: 'Inter',
                              letterSpacing: 0.5)),
                    ),
                    const Spacer(),
                    Text(n.time,
                        style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(n.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12, color: AppTheme.textPrimary),
                      overflow: TextOverflow.fade),
                ),
                const SizedBox(height: 8),
                Divider(
                    height: 1,
                    color: Colors.black.withValues(alpha: 0.06)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(n.avatarUrl)),
                    const SizedBox(width: 8),
                    Text(n.author,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMySchedules() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _mySchedules.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final s = _mySchedules[i];
          return Container(
            width: 240,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: s.isPrimary
                      ? AppTheme.primaryColor.withValues(alpha: 0.3)
                      : const Color(0xFFE2E8F0),
                  width: s.isPrimary ? 2 : 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                if (s.isPrimary)
                  Container(
                    width: 4,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(left: s.isPrimary ? 0 : 8),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: s.isPrimary
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: s.isPrimary
                              ? const Color(0xFFBFDBFE)
                              : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.weekday,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: s.isPrimary
                                    ? AppTheme.primaryColor
                                    : const Color(0xFF64748B),
                                fontFamily: 'Inter')),
                        Text('${s.day}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: s.isPrimary
                                    ? AppTheme.primaryColor
                                    : AppTheme.textPrimary,
                                fontFamily: 'Poppins',
                                height: 1.1)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text('${s.time} • ${s.location}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 11)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border:
                          Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(s.role,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                      fontFamily: 'Inter'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle_rounded,
                                size: 12, color: Color(0xFF22C55E)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrgEvents() {
    return Column(
      children: _orgEvents.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Column(
                    children: [
                      Text(e.weekday,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                              fontFamily: 'Inter')),
                      Text('${e.day}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontSize: 20, height: 1.1)),
                    ],
                  ),
                ),
                Container(
                    width: 1,
                    height: 36,
                    color: const Color(0xFFF1F5F9),
                    margin: const EdgeInsets.symmetric(horizontal: 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontSize: 13)),
                      Text('${e.time} • ${e.location}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                if (e.isClosed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 11, color: Color(0xFF94A3B8)),
                        SizedBox(width: 4),
                        Text('Fechada',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                                fontFamily: 'Inter')),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBirthdays() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: _birthdays.map((b) {
          return Expanded(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(b.avatarUrl)),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor,
                          borderRadius: BorderRadius.circular(20),
                          border:
                          Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(b.date,
                            style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Inter')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(b.name,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontSize: 11),
                    textAlign: TextAlign.center),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Swipe Card Stack ──────────────────────────────────────────────────────────

class _SwipeCardStack extends StatefulWidget {
  final List<PendingCard> cards;

  const _SwipeCardStack({required this.cards});

  @override
  State<_SwipeCardStack> createState() => _SwipeCardStackState();
}

class _SwipeCardStackState extends State<_SwipeCardStack>
    with SingleTickerProviderStateMixin {
  late List<PendingCard> _cards;
  Offset _dragOffset = Offset.zero;
  bool _isAnimatingOut = false;

  late AnimationController _exitController;
  late Animation<Offset> _exitAnimation;

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.cards);
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _exitController.dispose();
    super.dispose();
  }

  void _triggerExit(double direction) {
    if (_isAnimatingOut) return;
    final screenWidth = MediaQuery.of(context).size.width;

    _exitAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset(direction * (screenWidth + 200), _dragOffset.dy * 0.3),
    ).animate(
        CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic));

    setState(() => _isAnimatingOut = true);

    _exitController.forward(from: 0).then((_) {
      setState(() {
        final card = _cards.removeAt(0);
        _cards.add(card);
        _dragOffset = Offset.zero;
        _isAnimatingOut = false;
      });
      _exitController.reset();
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_isAnimatingOut) return;
    setState(() => _dragOffset += Offset(d.delta.dx, d.delta.dy * 0.2));
  }

  void _onPanEnd(DragEndDetails d) {
    if (_isAnimatingOut) return;
    if (_dragOffset.dx.abs() > 90) {
      _triggerExit(_dragOffset.dx > 0 ? 1 : -1);
    } else {
      setState(() => _dragOffset = Offset.zero);
    }
  }

  Offset get _topOffset =>
      _isAnimatingOut ? _exitAnimation.value : _dragOffset;

  // esquerda = disponível (verde), direita = indisponível (vermelho)
  double get _dragProgress => (_dragOffset.dx / 120).clamp(-1.0, 1.0);

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _exitController,
      builder: (context, _) {
        final topOffset = _topOffset;
        final rotation = topOffset.dx / 900;
        final cardOpacity = _isAnimatingOut
            ? (1.0 - _exitController.value).clamp(0.0, 1.0)
            : 1.0;
        final double dp = _isAnimatingOut ? 0 : _dragProgress;

        return SizedBox(
          height: 240,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Card 3
              if (_cards.length >= 3)
                Positioned.fill(
                  child: Transform.translate(
                    offset: const Offset(0, 24),
                    child: Transform.scale(
                      scale: 0.90,
                      child: _CardWidget(
                          card: _cards[2], opacity: 0.4, interactive: false),
                    ),
                  ),
                ),
              // Card 2
              if (_cards.length >= 2)
                Positioned.fill(
                  child: Transform.translate(
                    offset: const Offset(0, 12),
                    child: Transform.scale(
                      scale: 0.95,
                      child: _CardWidget(
                          card: _cards[1], opacity: 0.7, interactive: false),
                    ),
                  ),
                ),
              // Top card
              Positioned.fill(
                child: GestureDetector(
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Transform.translate(
                    offset: topOffset,
                    child: Transform.rotate(
                      angle: rotation,
                      alignment: Alignment.bottomCenter,
                      child: Opacity(
                        opacity: cardOpacity,
                        child: _CardWidget(
                          card: _cards[0],
                          dragProgress: dp,
                          interactive: true,
                          onAvailable: () => _triggerExit(-1),
                          onUnavailable: () => _triggerExit(1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Card Widget ───────────────────────────────────────────────────────────────

class _CardWidget extends StatelessWidget {
  final PendingCard card;
  final double opacity;
  final double dragProgress;
  final bool interactive;
  final VoidCallback? onAvailable;
  final VoidCallback? onUnavailable;

  const _CardWidget({
    required this.card,
    this.opacity = 1.0,
    this.dragProgress = 0.0,
    required this.interactive,
    this.onAvailable,
    this.onUnavailable,
  });

  // esquerda < 0 = disponível (verde), direita > 0 = indisponível (vermelho)
  bool get _showAvailable => dragProgress < -0.15;
  bool get _showUnavailable => dragProgress > 0.15;
  double get _badgeOpacity =>
      ((dragProgress.abs() - 0.15) / 0.85).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondaryColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Tint verde (disponível = esquerda)
              if (_showAvailable)
                Positioned.fill(
                  child: Opacity(
                    opacity: _badgeOpacity * 0.3,
                    child: Container(color: const Color(0xFF16A34A)),
                  ),
                ),
              // Tint vermelho (indisponível = direita)
              if (_showUnavailable)
                Positioned.fill(
                  child: Opacity(
                    opacity: _badgeOpacity * 0.3,
                    child: Container(color: const Color(0xFFDC2626)),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${card.index} • ${card.tag}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Inter',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(card.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 11, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(card.datetime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Hint de swipe
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back_rounded,
                            size: 11, color: Colors.white60),
                        const SizedBox(width: 4),
                        Text('Disponível',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.6),
                              fontFamily: 'Inter',
                            )),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Indisponível',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.6),
                              fontFamily: 'Inter',
                            )),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 11, color: Colors.white60),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Botões
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: interactive ? onAvailable : null,
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_rounded,
                                      size: 15,
                                      color: AppTheme.secondaryColor),
                                  SizedBox(width: 5),
                                  Text('Disponível',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.secondaryColor,
                                        fontFamily: 'Inter',
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: interactive ? onUnavailable : null,
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                Colors.black.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.15)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.close_rounded,
                                      size: 15, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text('Indisponível',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge DISPONÍVEL (arraste esquerda)
              if (_showAvailable)
                Positioned(
                  top: 18,
                  left: 18,
                  child: Opacity(
                    opacity: _badgeOpacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF16A34A), width: 2),
                      ),
                      child: const Text(
                        '✓ DISPONÍVEL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF16A34A),
                          fontFamily: 'Inter',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

              // Badge INDISPONÍVEL (arraste direita)
              if (_showUnavailable)
                Positioned(
                  top: 18,
                  right: 18,
                  child: Opacity(
                    opacity: _badgeOpacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFDC2626), width: 2),
                      ),
                      child: const Text(
                        '✗ INDISPONÍVEL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFDC2626),
                          fontFamily: 'Inter',
                          letterSpacing: 0.5,
                        ),
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
}