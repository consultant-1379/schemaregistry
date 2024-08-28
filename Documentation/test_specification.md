<html>

<head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<meta name=Generator content="Microsoft Word 15 (filtered)">
<title>Test Specification (APR201492 R1A)</title>
</head>

<body lang=EN-US link=blue vlink=purple style='word-wrap:break-word'>

<div class=WordSection1>

<h1>Test Specification ( APR201492 R1A)</h1>

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
  <p class=MsoNormal><strong>Schema Registry Test Specification</strong><br>
  ( APR201492 R1A)</p>
  </td>
 </tr>
 <tr style='page-break-inside:avoid'>
  <td style='border:solid windowtext 1.0pt;border-top:none;padding:3.75pt 3.75pt 3.75pt 3.75pt'
  data-highlight-colour=grey>
  <p class=MsoNormal><strong>Purpose</strong></p>
  </td>
  <td style='border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;padding:3.75pt 3.75pt 3.75pt 3.75pt'>
  <p>Describes the test cases used to verify the Schema Registry microservice.</p>
  <p>Functional Tests</p>
  <ul type=disc>
   <li class=MsoNormal>Verify installation of scheam registry service using helm chart and schema registry is dependent on message-bus-kafka. </li>
   <li class=MsoNormal>Deploy scheam registry chart with kafka and verify if
       schema registry service pod is deployed.&nbsp;</li>
   <li class=MsoNormal>Verify schema registry installation without Kafka. </li>
   <li class=MsoNormal>Verify Post (Create schema) </li>
   <li class=MsoNormal>Verify Post (Check if a schema has already been registered under the specified subject) </li>
   <li class=MsoNormal>Verify Get Schema</li>
   <li class=MsoNormal>Verify Get by Listing Schema by id </li>
   <li class=MsoNormal>Verify Get by Fetching the schema types</li>
   <li class=MsoNormal>Verify Get by Fetching a particular version of schema by id</li>
   <li class=MsoNormal>Verify Get subjects</li>
   <li class=MsoNormal>Verify Get by Fetching all schema register under subject</li>
   
   <li class=MsoNormal>Perform Delete the recently registered schema under subject</li>
   <li class=MsoNormal>Perform Delete a perticular registered subject</li>
   <li class=MsoNormal>Verify Get by Fetching the top level config (compatibility)</li>
   <li class=MsoNormal>Verify Put by Fetching the top level config (compatibility)</li>
   
  </ul>
  <p>Availability Test</p>
  <ul type=disc>
   <li class=MsoNormal>verify Scheam Registry only instance and verify POST/GET requests</li>

  </ul>
  <p>Robustness Test</p>
  <ul type=disc>
   <li class=MsoNormal>Verify Robustness, Service Restart</li>
   <li class=MsoNormal>Verify Liveness and Readiness probes test</li>
   <li class=MsoNormal>Verify SIGTERM and SIGKILL handling</li>
   <li class=MsoNormal>Verify Move between workers(draining nodes)</li>
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
