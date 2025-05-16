import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { AgentService } from '../../services/agent.service';
import { GrafanaFrameComponent } from '../grafana-frame/grafana-frame.component';
import { SafeUrlPipe } from '../../pipes/safe-url.pipe';
import { HttpClient } from '@angular/common/http';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';


@Component({
  selector: 'app-alerts',
  standalone: true,
imports: [
  CommonModule,
  MatCardModule,
  MatProgressSpinnerModule,
  MatButtonModule,
  MatIconModule,
  GrafanaFrameComponent,
  SafeUrlPipe,
],
  templateUrl: './alerts.component.html',
  styleUrls: ['./alerts.component.css'],
})
export class AlertsComponent {
  agentSrv = inject(AgentService);

   http = inject(HttpClient);

  // Descarga las alertas del agente seleccionado
  downloadCurrentAgentAlerts(): void {
    const agent = this.agentSrv.current;
    if (!agent) return;

    const url = `http://${agent.ip}:9000/download-alerts`;
    window.open(url, '_blank');
  }

  // Descarga todas las alertas (desde el módulo central)
  downloadAllAlerts(): void {
    const centralIp = this.agentSrv.getAll().find(a => a.id === 'central')?.ip;
    if (!centralIp) {
      console.error('No se encontró el agente central');
      return;
    }

    const url = `http://${centralIp}:9000/download-alerts`;
    window.open(url, '_blank');
  }
}