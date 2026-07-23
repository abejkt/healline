import '../models/active_queue_status.dart';
import '../services/queue_service.dart';
import '../themes/app_theme.dart';
import 'ambil_antrian_screen.dart';
import 'status_antrian_screen.dart';

class TiketAntrianScreen extends StatefulWidget {
  static const routeName = '/tiket-antrian';

  const TiketAntrianScreen({super.key});

  @override
  State<TiketAntrianScreen> createState() => _TiketAntrianScreenState();
}

class _TiketAntrianScreenState extends State<TiketAntrianScreen> {
  final QueueService _queueService = QueueService();
  UpcomingQueue? _ticket;
  bool _isLoading = true;
  String? _passedTicketNumber;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get ticket number from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && _passedTicketNumber == null) {
      _passedTicketNumber = args;
      _fetchTicket(args);
    } else if (args == null && _isLoading && _passedTicketNumber == null) {
      // Fallback for demo if no args provided
      _passedTicketNumber = 'A-042';
      _fetchTicket('A-042');
    }
  }

  Future<void> _fetchTicket(String ticketNumber) async {
    setState(() => _isLoading = true);
    try {
      // Fetch from upcoming_queues table
      final upcoming = await _queueService.fetchUpcomingQueues(AuthService.currentUser?.id ?? '');
      final ticket = upcoming.firstWhere((t) => t.ticketNumber == ticketNumber);
      
      setState(() {
        _ticket = ticket;
      });
    } catch (e) {
      debugPrint('Error fetching ticket: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Tiket antrian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: share the ticket (deep link or image) with the user.
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _ticket == null
                ? const Center(child: Text('Tiket tidak ditemukan'))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      _TicketCard(ticket: _ticket!),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, StatusAntrianScreen.routeName);
                        },
                        icon: const Icon(Icons.north_east, size: 18),
                        label: const Text('Pantau status antrian'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          // TODO: export/download the ticket as a PDF.
                        },
                        child: const Text('Unduh tiket (PDF)'),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: buildAntrianBottomNav(context, currentIndex: 1),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final UpcomingQueue ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'HealLine',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ticket.ticketNumber,
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlue,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Nomor antrian Anda',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          const _DashedDivider(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _TicketDetail(label: 'Poliklinik', value: ticket.poliName),
              ),
              Expanded(
                child: _TicketDetail(label: 'Dokter', value: ticket.doctorName),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TicketDetail(label: 'Tanggal', value: ticket.scheduleLabel),
              ),
              Expanded(
                child: _TicketDetail(label: 'Pasien', value: ticket.patientName),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _TicketCodePlaceholder(),
          const SizedBox(height: 12),
          const Text(
            'Tunjukkan kode ini di loket',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TicketDetail extends StatelessWidget {
  final String label;
  final String value;
  const _TicketDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 6.0;
          const dashSpace = 5.0;
          final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
          return Row(
            children: List.generate(count, (_) {
              return Padding(
                padding: const EdgeInsets.only(right: dashSpace),
                child: Container(
                  width: dashWidth,
                  height: 1,
                  color: AppColors.inputBorder,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _TicketCodePlaceholder extends StatelessWidget {
  const _TicketCodePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const Positioned(top: 0, left: 0, child: _CornerMarker()),
          const Positioned(top: 0, right: 0, child: _CornerMarker()),
          const Positioned(bottom: 0, left: 0, child: _CornerMarker()),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Container(
                    width: 46 - (i.isEven ? 0 : 10),
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerMarker extends StatelessWidget {
  const _CornerMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
