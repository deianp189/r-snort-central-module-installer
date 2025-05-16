package com.rsnort.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.rsnort.model.Agent;
import org.springframework.stereotype.Service;

import java.io.File;
import java.util.List;

@Service
public class AgentService {
    private final File agentFile = new File("/etc/rsnort-backend/agents.json");
    private final ObjectMapper mapper = new ObjectMapper();

    public List<Agent> getAgents() throws Exception {
        if (!agentFile.exists()) {
            throw new Exception("El archivo /etc/rsnort-backend/agents.json no existe");
        }
        return mapper.readValue(agentFile, new TypeReference<List<Agent>>() {
        });
    }

    public void saveAgents(List<Agent> agents) throws Exception {
        mapper.writerWithDefaultPrettyPrinter().writeValue(agentFile, agents);
    }

    public void addAgent(Agent newAgent) throws Exception {
        List<Agent> current = getAgents();
        boolean exists = current.stream()
                .anyMatch(a -> a.getId().equals(newAgent.getId()) || a.getIp().equals(newAgent.getIp()));
        if (!exists) {
            current.add(newAgent);
            saveAgents(current);
        } else {
            throw new Exception("Agente ya existe");
        }
    }

    public void deleteAgent(String id) throws Exception {
        List<Agent> current = getAgents();
        boolean removed = current.removeIf(a -> a.getId().equals(id));
        if (removed) {
            saveAgents(current);
        } else {
            throw new Exception("Agente no encontrado");
        }
    }

}
