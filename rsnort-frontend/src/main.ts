import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { provideRouter } from '@angular/router';
import { routes } from './app/app.routes';
import { provideHttpClient, withInterceptorsFromDi } from '@angular/common/http';
import { HTTP_INTERCEPTORS } from '@angular/common/http';
import { JwtInterceptor } from './app/interceptors/jwt.interceptor';
import { APP_INITIALIZER } from '@angular/core';
import { AgentService } from './app/services/agent.service';

// export function preloadAgents(agentSrv: AgentService) {
//   return () => agentSrv.load();    // ⇢ devuelve una Promise<void>
// }

export function preloadAgents(agentSrv: AgentService) {
  return () =>
    agentSrv.load().catch(err => {
      console.error('[APP_INITIALIZER] Error:', err);
      return Promise.resolve();
    });
}

bootstrapApplication(AppComponent, {
  providers: [
    provideHttpClient(withInterceptorsFromDi()),
    provideRouter(routes),
    {
      provide: APP_INITIALIZER,
      useFactory: preloadAgents,
      deps: [AgentService],
      multi: true
    },
    { provide: HTTP_INTERCEPTORS, useClass: JwtInterceptor, multi: true }
  ]
});
