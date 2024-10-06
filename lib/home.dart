import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'location_result.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _cepController = TextEditingController();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false; // Variável para controlar o estado de loading

  // Função para buscar o CEP
  Future<void> _buscarCep() async {
    final cep = _cepController.text.trim(); // Remove espaços em branco

    // Validação do CEP
    if (cep.isEmpty || cep.length != 8) {
      _showSnackBar('Por favor, insira um CEP válido com 8 dígitos.');
      return;
    }

    setState(() {
      _isLoading = true; // Inicia o loading
    });

    try {
      final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('erro')) {
          _showSnackBar('CEP inválido.');
        } else {
          final info = {
            'cep': cep,
            'logradouro': data['logradouro'] ?? 'N/A',
            'bairro': data['bairro'] ?? 'N/A',
            'cidade': data['localidade'] ?? 'N/A',
            'estado': data['uf'] ?? 'N/A',
          };

          setState(() {
            _history.add(info);
          });

          // Navega para a página de resultado
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocationResult(info: info),
            ),
          );
        }
      } else {
        _showSnackBar('Erro ao buscar o CEP.');
      }
    } catch (e) {
      _showSnackBar('Erro de conexão. Tente novamente.');
    } finally {
      setState(() {
        _isLoading = false; // Finaliza o loading
      });
    }
  }

  // Função para exibir mensagens de erro
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fast Location',
          style: TextStyle(color: Colors.green[300]), // Verde pastel no título
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  'Digite o CEP:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                // Campo de texto para o CEP
                TextField(
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'CEP',
                    hintText: 'Ex: 12345678', // Exemplo de formato de CEP
                  ),
                  maxLength: 8, // Limita a entrada a 8 caracteres
                ),
                SizedBox(height: 16),
                // Botão para procurar CEP
                ElevatedButton(
                  onPressed: _isLoading ? null : _buscarCep, // Desabilita o botão durante o loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[300], // Verde pastel no botão
                  ),
                  child: Text('Buscar CEP'),
                ),
                SizedBox(height: 16),
                // Histórico de buscas
                Text(
                  'Histórico de buscas:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      return Card(
                        color: Colors.green[100], // Fundo verde pastel no Card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Bordas arredondadas
                        ),
                        child: ListTile(
                          title: Text('CEP: ${item['cep']}'),
                          subtitle: Text('''
                            Logradouro: ${item['logradouro']}
                            Bairro: ${item['bairro']}
                            Cidade: ${item['cidade']}
                            Estado: ${item['estado']}
                          '''),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Exibe o loading enquanto busca o CEP
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // Fundo semitransparente
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[300]!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}