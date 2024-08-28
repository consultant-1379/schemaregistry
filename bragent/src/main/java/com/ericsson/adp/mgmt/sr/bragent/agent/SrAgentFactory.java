/*------------------------------------------------------------------------------
 *******************************************************************************
 * COPYRIGHT Ericsson 2021
 *
 * The copyright to the computer program(s) herein is the property of
 * Ericsson Inc. The programs may be used and/or copied only with written
 * permission from Ericsson Inc. or in accordance with the terms and
 * conditions stipulated in the agreement/contract under which the
 * program(s) have been supplied.
 *******************************************************************************
 *----------------------------------------------------------------------------*/

package com.ericsson.adp.mgmt.sr.bragent.agent;

import javax.annotation.PostConstruct;

import com.ericsson.adp.mgmt.bro.api.agent.Agent;
import com.ericsson.adp.mgmt.bro.api.agent.AgentFactory;
import com.ericsson.adp.mgmt.bro.api.agent.OrchestratorConnectionInformation;
import com.ericsson.adp.mgmt.bro.api.agent.RestoreExecutionActions;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Creates the br agent.
 */
@Component
public class SrAgentFactory {

    @Value("${bro.host}")
    private String orchestratorHost;
    @Value("${bro.port}")
    private int orchestratorPort;

    @Value("${siptls.security.enabled}")
    private String tlsEnabled;
    @Value("${siptls.ca.name}")
    private String certificationAuthorityName;
    @Value("${siptls.ca.path}")
    private String certificateAuthorityPath;
    @Value("${siptls.bro.client.cert.file}")
    private String clientCert;
    @Value("${siptls.bro.client.cert.keyfile}")
    private String clientPrivateKey;

    private Agent agent;

    private RestoreExecutionActions restoreExecutionActions;

    @Autowired
    private SrAgentBehaviour agentBehaviour;

    @PostConstruct
    private void createAgentAndBackupExecutions() {
        OrchestratorConnectionInformation orchestratorConnectionInformation;

        if ("true".equalsIgnoreCase(tlsEnabled)) {
            orchestratorConnectionInformation = new OrchestratorConnectionInformation(orchestratorHost, orchestratorPort, certificationAuthorityName,
                    certificateAuthorityPath, clientCert, clientPrivateKey);
        } else {
            orchestratorConnectionInformation = new OrchestratorConnectionInformation(orchestratorHost, orchestratorPort);
        }

        agent = AgentFactory.createAgent(orchestratorConnectionInformation, agentBehaviour);
    }

    public RestoreExecutionActions getRestoreExecutionActions() {
        return restoreExecutionActions;
    }

    public Agent getAgent() {
        return agent;
    }
}
