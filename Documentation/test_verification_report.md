<html>

<head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<meta name=Generator content="Microsoft Word 15 (filtered)">
<title>Test Report / Verification Report (APR201492 R1A)</title>
</head>

<body lang=EN-US link=blue vlink=purple style='word-wrap:break-word'>

<div class=WordSection1>

<h1>Test Verification Report (APR201492 R1A)</h1>

<div>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=1085
 style='width:813.75pt;border-collapse:collapse;border:none'>
 <colgroup><col><col></colgroup>
 <tr style='page-break-inside:avoid'>
  <td style='border:solid windowtext 1.0pt;padding:3.75pt 3.75pt 3.75pt 3.75pt'
  data-highlight-colour=grey>
  <p><strong>Document Title</strong><b><br>
  </b>(including document number)</p>
  </td>
  <td style='border:solid windowtext 1.0pt;border-left:none;padding:3.75pt 3.75pt 3.75pt 3.75pt'>
  <p class=MsoNormal><strong>Schema Registry/Test Verification Report </strong><br>
  (APR201492 R1A)</p>
  </td>
 </tr>
 <tr style='page-break-inside:avoid'>
  <td style='border:solid windowtext 1.0pt;border-top:none;padding:3.75pt 3.75pt 3.75pt 3.75pt'
  data-highlight-colour=grey>
  <p class=MsoNormal><strong>Purpose</strong></p>
  </td>
  <td style='border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;padding:3.75pt 3.75pt 3.75pt 3.75pt'>
  <p>Schema Registry Service latest chart is verified both by manual cases and internal CI loop which includes functional cases.</p>
  <p><strong>Test Tools</strong></p>
  <p>It is required to have some tools to automate functional tests and to send concurrent/sequential API requests for Schema Registry Service. The details of tools used are as below:</p>
  <ul type=disc>
   <li class=MsoNormal>Contract Testing: An open source testing tool that helps in interrogation of a deployed or mocked services endpoint.</li>
   <li class=MsoNormal>Jmeter: An open source testing tool that helps us in concurrent testing and Performace testing by giving load to the API's.</li> 
  </ul>
  <p><strong>Test Environment</strong></p>
  <ul type=disc>
   <li class=MsoNormal>Helm Version v3.6.3</li>
   <li class=MsoNormal>Kubernetes Client Version v1.28.4</li>
   <li class=MsoNormal>Kubernetes Server Version v1.28.4</li>
   <li class=MsoNormal>Kubernetes master is running at Kaas cluster </li>
  </ul>
  <p><strong>Cluster Information</strong></p>
  <p>Below Kaas cluster is used for both functional and load automated tests</p>
  <ul type=disc>
   <li class=MsoNormal>Cluster Topology: 3 master, 8 worker nodes</li>
   <li class=MsoNormal>Cluster Name: hall144</li>
   <li class=MsoNormal>Kaas Version: 1.28.4-kaas.1</li>
   <li class=MsoNormal>kubernetes version: v1.28.4	
</li>
   <p><strong>Worker nodes list:</strong></p>
   <p>NAME STATUS ROLES AGE VERSION</p>
   <p>node-10-156-77-44 Ready,SchedulingDisabled  edge,node 569d v1.28.4</p>
   <p>node-10-156-77-45 Ready edge,node 569d v1.28.4</p>
   <p>node-10-156-77-46 Ready node 569d v1.28.4</p>
   <p>node-10-156-77-47 Ready node 569d v1.28.4</p>
   <p>node-10-156-77-48 Ready node 569d v1.28.4</p>
   <p>node-10-156-77-49 Ready node 569d v1.28.4</p>
   <p>node-10-156-77-50 Ready node 569d v1.28.4</p>
   <p>node-10-156-77-51 Ready node 569d v1.28.4</p>
   <p>node-10-156-82-169 Ready controlplane,master 569d v1.28.4</p>
   <p>node-10-156-82-170 Ready controlplane,master 569d v1.28.4</p>
   <p>node-10-156-82-171 Ready controlplane,master 569d v1.28.4</p>
  </ul>
  <p><strong>Functional Tests</strong></p>
  <ul type=disc>
  <li class=MsoNormal>All the test cases were executed with below default configuration of Schema Registry Service</li>
  <p><strong>Request:</strong></p>
  <p>resource.schemaregistry.requests.cpu=100m</p> 
  <p>resource.schemaregistry.requests.memory=800Mi</p>
  <p><strong>Limit:</strong></p>
  <p>resource.schemaregistr.limits.cpu=600m</p> 
  <p>resource.schemaregistr.limits.memory=1Gi</p>
  <li class=MsoNormal>Schema Registry Service chart deployments test is verified using below CI job</li>
  <p> 
<a
href="https://arm.seli.gic.ericsson.se/artifactory/proj-eric-oss-drop-helm-local/eric-oss-schema-registry-sr/">https://arm.seli.gic.ericsson.se/artifactory/proj-eric-oss-drop-helm-local/eric-oss-schema-registry-sr/ </a></p>
</ul>
<p><strong>SonarQube Report</strong></p>
<ul type=disc>
 <p><img border=0 width=800 height=104 id="Picture 1" src="capture.png"></p>
 <li class=MsoNormal>Schema Registry HA tests automated results  </li>
 <li class=MsoNormal>Graceful shutdown of Schema Registry service pod which ensures that pod is terminated efficiently. Graceful shutdown test results</li>
 <li class=MsoNormal>Schema Registry Load Tests </li>
 </ul>
 <p><strong>Availability Tests</strong></p>
 <li class=MsoNormal>1 use cases passed with manual tests</li>
  </ul>
 <p><strong>Robustness Tests</strong></p>
 <li class=MsoNormal>4 use cases passed with manual tests</li>
  </ul>
  </td>
 </tr>
 <tr style='page-break-inside:avoid'>
  <td style='border:solid windowtext 1.0pt;border-top:none;padding:3.75pt 3.75pt 3.75pt 3.75pt'
  data-highlight-colour=grey>
  <p class=MsoNormal><strong>Target audience</strong></p>
  </td>
  <td style='border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;padding:3.75pt 3.75pt 3.75pt 3.75pt'>
  <ul type=disc>
   <li class=MsoNormal>Applications development team and Architects&nbsp;</li>
  </ul>
  </td>
 </tr>
 <tr style='page-break-inside:avoid'>
  <td style='border:solid windowtext 1.0pt;border-top:none;padding:3.75pt 3.75pt 3.75pt 3.75pt'
  data-highlight-colour=grey>
  <p><strong>Available when?</strong></p>
  </td>
  <td style='border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;padding:3.75pt 3.75pt 3.75pt 3.75pt'>
  <p class=MsoNormal>At release time.</p>
  </td>
 </tr>
</table>

</div>



<div>

<p class=MsoNormal>&nbsp;</p>

</div>

</div>

</body>

</html>
