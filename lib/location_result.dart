import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationResult extends StatelessWidget {
  final Map<String, dynamic> info;

  LocationResult({required this.info});

  Future<void> _openMap(String cep) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$cep');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir o mapa.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultado da Busca'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Endereço',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 16),
            // Informações do endereço
            _buildInfoRow('CEP:', info['cep'] ?? 'N/A'),
            _buildInfoRow('Rua:', info['logradouro'] ?? 'N/A'),
            _buildInfoRow('Bairro:', info['bairro'] ?? 'N/A'),
            _buildInfoRow('Cidade:', info['cidade'] ?? 'N/A'),
            _buildInfoRow('Estado:', info['estado'] ?? 'N/A'),
            SizedBox(height: 24),
            // Botão "Olhar no mapa"
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _openMap(info['cep'] ?? ''),
                icon: Icon(Icons.map),
                label: Text('Olhar no mapa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}