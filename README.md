# new_inventario# 🖥️ Script de Inventário Automático — `inv.bat`

Script em batch + PowerShell desenvolvido para automatizar a **coleta e envio de informações de inventário de notebooks** da Projeta.  
Ele coleta dados do equipamento (BIOS, hardware, rede e sistema operacional) e envia automaticamente para a API FastAPI hospedada no endpoint interno da rede.

---

## 🧩 Descrição

O arquivo `inv.bat` realiza automaticamente o **inventário local da máquina** onde é executado e envia esses dados para uma **API REST** configurada na variável `API_URL`.

A execução pode ser feita manualmente, via *Task Scheduler*, ou integrada em políticas de logon/logoff no Windows.

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

## 👤 Autor

Desenvolvido por **Sala Técnica — Projeta Consultoria**  
📧 anderson.marley@projeta.com

---

## 🪪 Licença

Este projeto está sob a **MIT License** — veja o arquivo [LICENSE](LICENSE) para detalhes.
