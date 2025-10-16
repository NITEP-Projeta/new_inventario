# new_inventario# 🖥️ Script de Inventário Automático — `inv.bat`

Script em batch + PowerShell desenvolvido para automatizar a **coleta e envio de informações de inventário de notebooks** da Projeta.  
Ele coleta dados do equipamento (BIOS, hardware, rede e sistema operacional) e envia automaticamente para a API FastAPI hospedada no endpoint interno da rede.

---

## 📋 Sumário
- [Descrição](#descrição)
- [Fluxo de Funcionamento](#fluxo-de-funcionamento)
- [Informações Coletadas](#informações-coletadas)
- [Configurações](#configurações)
- [Requisitos](#requisitos)
- [Execução](#execução)
- [Exemplo de Saída JSON](#exemplo-de-saída-json)
- [Integração com FastAPI](#integração-com-fastapi)
- [Logs e Status](#logs-e-status)
- [Autor](#autor)
- [Licença](#licença)

---

## 🧩 Descrição

O arquivo `inv.bat` realiza automaticamente o **inventário local da máquina** onde é executado e envia esses dados para uma **API REST** configurada na variável `API_URL`.

A execução pode ser feita manualmente, via *Task Scheduler*, ou integrada em políticas de logon/logoff no Windows.

---

## ⚙️ Fluxo de Funcionamento

1. **Inicialização**  
   O script desativa o eco do console (`@echo off`) e define variáveis de ambiente locais, como:
   ```cmd
   set "STATUS=login"
   set "API_URL=http://192.168.15.102:8000/inventario"
   ```

2. **Coleta de Informações Locais**  
   Através do PowerShell embutido, ele coleta:
   - BIOS (`Win32_BIOS`)
   - Sistema (`Win32_ComputerSystem`)
   - Produto (`Win32_ComputerSystemProduct`)
   - Sistema Operacional (`Win32_OperatingSystem`)
   - IP e MAC Address (`Get-NetIPAddress`, `Get-NetAdapter`)

3. **Montagem do Objeto JSON**  
   Cria um objeto com os campos:
   ```json
   {
     "timestamp": "2025-10-16T14:00:00Z",
     "user": "usuario",
     "hostname": "DELLG15",
     "domain": "PROJETA",
     "fabricante": "Dell Inc.",
     "modelo": "G15 5530",
     "serial": "ABC123XYZ",
     "so": "Windows 11 Pro",
     "ip": "192.168.15.12",
     "mac": "00-1A-2B-3C-4D-5E",
     "status": "login"
   }
   ```

4. **Envio à API**  
   Os dados são enviados com:
   ```powershell
   Invoke-RestMethod -Uri $env:API_URL -Method POST -Body ($obj | ConvertTo-Json) -ContentType "application/json"
   ```

5. **Tratamento de Erros**  
   Caso o envio falhe, o script captura a exceção (`try/catch`) e registra no console o erro ocorrido.

---

## 🧾 Informações Coletadas

| Categoria | Dados coletados | Fonte PowerShell |
|------------|-----------------|------------------|
| Sistema | Nome do computador, domínio, usuário logado | `%COMPUTERNAME%`, `%USERDOMAIN%`, `%USERNAME%` |
| Hardware | Fabricante, modelo, número de série | `Win32_ComputerSystem`, `Win32_ComputerSystemProduct` |
| BIOS | Versão e fornecedor da BIOS | `Win32_BIOS` |
| Sistema Operacional | Nome, versão e build | `Win32_OperatingSystem` |
| Rede | IP ativo e endereço MAC | `Get-NetIPAddress`, `Get-NetAdapter` |
| Data e hora | Timestamp ISO 8601 | `Get-Date` |

---

## ⚙️ Configurações

Você pode personalizar o comportamento do script alterando as variáveis no início:

```cmd
set "STATUS=login"                :: Define o tipo de evento (login, logoff, inventário)
set "API_URL=http://192.168.15.102:8000/inventario"
```

> 💡 **Dica:**  
> Para uso em múltiplas estações, utilize o mesmo script e altere apenas o endpoint via variável de ambiente no Windows ou GPO.

---

## 🧰 Requisitos

- Windows 10/11  
- PowerShell 5.1+  
- Permissões de execução de scripts (ExecutionPolicy Bypass)  
- Conexão de rede com a API configurada  

---

## ▶️ Execução

### 1. Manual
Abra o *Prompt de Comando* e execute:
```cmd
inv.bat
```

### 2. Agendada
Para rodar automaticamente no logon:
- Abra o **Agendador de Tarefas (Task Scheduler)**
- Crie uma nova tarefa → *Ao fazer logon do usuário*
- Ação: `Iniciar um programa`
- Programa/script: `C:\Caminho\inv.bat`

---

## 📦 Exemplo de Saída JSON

```json
{
  "timestamp": "2025-10-16T13:43:52.394Z",
  "user": "victor.hugo",
  "hostname": "DELLG15",
  "domain": "PROJETA",
  "fabricante": "Dell Inc.",
  "modelo": "G15 5530",
  "serial": "ABC123XYZ",
  "so": "Windows 11 Pro",
  "ip": "192.168.15.12",
  "mac": "00-1A-2B-3C-4D-5E",
  "status": "login"
}
```

---

## 🔗 Integração com FastAPI

O script foi desenvolvido para se integrar diretamente com o endpoint Python FastAPI do inventário:

```python
@app.post("/inventario")
def receber_dados(dados: dict):
    # Exemplo de persistência
    db.add(Dispositivo(**dados))
    db.commit()
```

> Endpoint padrão:  
> `http://192.168.15.102:8000/inventario`

---

## 🧩 Logs e Status

O campo `STATUS` pode ser utilizado para diferenciar o tipo de evento:
| Valor | Finalidade |
|--------|-------------|
| `login` | Registro de logon de usuário |
| `logoff` | Registro de logoff |
| `inventario` | Execução manual ou periódica para auditoria |

---

## 👤 Autor

Desenvolvido por **Sala Técnica — Projeta Consultoria**  
📧 contato@projeta.com.br  
🏢 [https://www.projetaconsultoria.com.br](https://www.projetaconsultoria.com.br)

---

## 🪪 Licença

Este projeto está sob a **MIT License** — veja o arquivo [LICENSE](LICENSE) para detalhes.
