
<cfif isdefined("attributes.genelchart")>
 
<cfquery name="get_lig" datasource="#dsn_mobile#">
    SELECT ISNULL(SIRA,3) AS SIRA,* FROM SETUP_LIG WHERE LIG_ID != 17
</cfquery>
<div id="Lig_Chart"></div> 
 <script>
    // Create the chart
   Highcharts.setOptions({
       colors: ['#D32F2F', '#DD161F', '#FF1722', '#F44336', '#EB3500', '#B71C1C', '#EF9A9A', '#E57373', '#EF5350', '#897879']
   });
   Highcharts.chart('Lig_Chart', {
       chart: {
           type: 'column'
       },
       title: {
           text: ''
       },
       subtitle: {
           text: ''
       },
       accessibility: {
           announceNewData: {
               enabled: true
           }
       },
       xAxis: {
           type: 'category'
       },
       yAxis: {
           title: {
               text: 'Puan (avg)'
           }
       },
       legend: {
           enabled: false
       },
       plotOptions: {
           series: {
               borderWidth: 0,
               dataLabels: {
                   enabled: true,
                   format: '{point.y:.1f}%'
               },
               events: {
                   click: function(event) {
                       var ligName = event.point.name;
                       var puan = event.point.y.toFixed(2);
                       var lig_Id= event.point.options.id
                        getDetail(lig_Id);
   
                   }
               }
           }
       },
       tooltip: {
           headerFormat: '',
           pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y:.2f}%</b><br/>'
       },
       series: [
           {
               name: "Browsers",
               colorByPoint: true,
               dataLabels: {
                   color: ''
               },
               data: [
                   <cfoutput query="get_lig">
                       <cfquery name="Get_Lig_Ortalama" datasource="#dsn_mobile#">
                           SELECT 
                               SUM(PUAN)/(SELECT 
                               COUNT(DISTINCT C.COMPANY_ID)
                               FROM BAYILIGI_PUAN BP
                               LEFT JOIN COMPANY C ON C.COMPANY_ID = BP.COMPANY_ID
                               LEFT JOIN SETUP_LIG SL ON SL.LIG_ID = C.LIG_ID
                               WHERE LIG_NAME IS NOT NULL AND SL.LIG_ID=#LIG_ID#
                               <cfif isdefined("attributes.ay_id")>
                                   AND BP.AY_ID =#attributes.ay_id#
                               </cfif>
                           ) AS ORTALAMA_PUAN, 
                           LIG_NAME 
                           FROM BAYILIGI_PUAN BP
                           LEFT JOIN COMPANY C ON C.COMPANY_ID = BP.COMPANY_ID
                           LEFT JOIN SETUP_LIG SL ON SL.LIG_ID = C.LIG_ID
                           WHERE LIG_NAME IS NOT NULL AND SL.LIG_ID=#LIG_ID#
                           <cfif isdefined("attributes.ay_id")>
                               AND BP.AY_ID =#attributes.ay_id#
                           </cfif>
                           GROUP BY  LIG_NAME
                       </cfquery>
                       {
                           name: '#Get_Lig_Ortalama.LIG_NAME#',
                           id: '#get_lig.LIG_ID#',
                           y: #Get_Lig_Ortalama.ORTALAMA_PUAN#,
                       },
                   </cfoutput>
               ]
           }
       ]
   });
    function getDetail(lig_Id){
         url_ = `<cfoutput>index.cfm?fuseaction=#module_name#.emptypopup_directionpage&issahamudurpage=1&lig_id=${lig_Id}<cfif isdefined("attributes.ay_id")>&ay_id=#attributes.ay_id#</cfif></cfoutput>`;
           $.ajax({
               type: "POST",
               url: url_,
                success: function(data){   
                    console.log(data);
                    $(`#Lig_Chart`).html(data);  
                    $(`.redirect`).removeClass('d-none');  
               }
           });     
       }
    function get_detail_return(){
         url_ = `<cfoutput>index.cfm?fuseaction=#module_name#.emptypopup_directionpage&genelchart=1<cfif isdefined("attributes.ay_id")>&ay_id=#attributes.ay_id#</cfif></cfoutput>`;
           $.ajax({
               type: "POST",
               url: url_,
                success: function(data){   
                    console.log(data);
                    $(`#Lig_Chart`).html(data);  
                    $(`.redirect`).removeClass('d-none');  
               }
           });     
       }
   </script> 
   
<cfelseif isdefined("attributes.issahamudurpage")>    

<div id="chart"></div> 
<cfquery name="getligt" datasource="#dsn_mobile#">
    SELECT * FROM SETUP_LIG WHERE LIG_ID = #attributes.lig_id#
</cfquery>

<cfquery name="getkriter" datasource="#dsn_mobile#">
    SELECT * FROM SETUP_PUAN_KRITER 
    WHERE LEAGUE_ID = #attributes.lig_id#
    ORDER BY KRITERSIRA ASC
</cfquery>  
    <script>  
 
 
               var options = {
                series: [{
                name: 'Lig Ortalamam',
                data:  [ <cfoutput query="getkriter">
                                
                                <cfquery name="Get_Lig_Ortalama" datasource="#dsn_mobile#">
                                    SELECT 
                                        SUM(PUAN)/(SELECT 
                                        COUNT(DISTINCT C.COMPANY_ID)
                                    FROM BAYILIGI_PUAN BP
                                    LEFT JOIN COMPANY C ON C.COMPANY_ID = BP.COMPANY_ID
                                    LEFT JOIN PO_USER_GROUP_STATION FF ON FF.PO_STATION_CODE = C.OZEL_KOD  
                                    LEFT JOIN SETUP_PUAN_KRITER SPK ON SPK.ID = BP.PUAN_KRITER_ID 
                                    WHERE PUAN_KRITER IS NOT NULL AND SPK.ID=#ID# AND  BP.AY_ID = (MONTH(GETDATE())-1)    
                                    <!---AND MIRROR_saha_MUDURU = #attributes.kisi_id# --->
                                    AND FF.PO_USERID = #get_kisi.PO_USERID#
                                    <cfif len(attributes.lig_id)>
                                        AND C.LIG_ID = #attributes.lig_id#
                                    </cfif>
                                    <cfif isdefined("attributes.ay_id")>
                                        AND BP.AY_ID =#attributes.ay_id#
                                    </cfif>
                                    GROUP BY  PUAN_KRITER) AS ORTALAMA_PUAN, 
                                    PUAN_KRITER 
                                    FROM BAYILIGI_PUAN BP
                                    LEFT JOIN COMPANY C ON C.COMPANY_ID = BP.COMPANY_ID
                                    LEFT JOIN PO_USER_GROUP_STATION FF ON FF.PO_STATION_CODE = C.OZEL_KOD  

                                    LEFT JOIN SETUP_PUAN_KRITER SPK ON SPK.ID = BP.PUAN_KRITER_ID 
                                    WHERE PUAN_KRITER IS NOT NULL AND SPK.ID=#ID# AND BP.AY_ID = (MONTH(GETDATE())-1)   
                                    AND FF.PO_USERID = #get_kisi.PO_USERID#
                                    AND LEN(SPK.PUAN_KRITER) > 0 
                                    <cfif len(attributes.lig_id)>
                                        AND C.LIG_ID = #attributes.lig_id#
                                    </cfif>
                                    <cfif isdefined("attributes.ay_id")>
                                        AND BP.AY_ID =#attributes.ay_id#
                                    </cfif>
                                    GROUP BY  PUAN_KRITER
                                </cfquery>
                                <cfif len(Get_Lig_Ortalama.ORTALAMA_PUAN)>#tlformat(Get_Lig_Ortalama.ORTALAMA_PUAN,2)#,<cfelse>0,</cfif>
                                </cfoutput>]
                }, 
                {
                name: 'Genel Lig Ortalaması',
                data:  [ 
                            
                            <cfoutput query="getkriter">
                            
                            <cfquery name="Get_Lig_Ortalama2" datasource="#dsn_mobile#">
                                SELECT 
                                    SUM(PUAN)/(SELECT 
                                    COUNT(DISTINCT C.COMPANY_ID)
                                FROM BAYILIGI_PUAN BP
                                LEFT JOIN COMPANY C ON C.COMPANY_ID = BP.COMPANY_ID
                                LEFT JOIN SETUP_PUAN_KRITER SPK ON SPK.ID = BP.PUAN_KRITER_ID 
                                WHERE PUAN_KRITER IS NOT NULL AND SPK.ID=#ID# AND  BP.AY_ID = (MONTH(GETDATE())-1)    
                                <cfif len(attributes.lig_id)>
                                    AND C.LIG_ID = #attributes.lig_id#
                                </cfif>
                                <cfif isdefined("attributes.ay_id")>
                                    AND BP.AY_ID =#attributes.ay_id#
                                </cfif>
                                GROUP BY  PUAN_KRITER) AS ORTALAMA_PUAN, 
                                PUAN_KRITER 
                                FROM BAYILIGI_PUAN BP
                                LEFT JOIN COMPANY C ON C.COMPANY_ID = BP.COMPANY_ID
                                LEFT JOIN SETUP_PUAN_KRITER SPK ON SPK.ID = BP.PUAN_KRITER_ID 
                                WHERE PUAN_KRITER IS NOT NULL AND SPK.ID=#ID# AND BP.AY_ID = (MONTH(GETDATE())-1) AND 
                                LEN(SPK.PUAN_KRITER) > 0 
                                <cfif len(attributes.lig_id)>
                                    AND C.LIG_ID = #attributes.lig_id#
                                </cfif>
                                <cfif isdefined("attributes.ay_id")>
                                    AND BP.AY_ID =#attributes.ay_id#
                                </cfif>
                                GROUP BY  PUAN_KRITER
                            </cfquery>
                             <cfif Get_Lig_Ortalama2.recordCount>#tlformat(Get_Lig_Ortalama2.ORTALAMA_PUAN,2)#,<cfelse>0,</cfif>
                            </cfoutput>]
                }],
                chart: {
                type: 'bar',
                height: 450
                },
                plotOptions: {
                bar: {
                    horizontal: false,
                    columnWidth: '75%',
                    endingShape: 'rounded'
                },
                },
                dataLabels: {
                enabled: true
                },
                stroke: {
                    show: true,
                    width: 2,
                    colors: ['transparent']
                },
                xaxis: { 
                categories: [     
                            <cfoutput query="getkriter"> 
                                 <cfset parcalar = ListToArray(PUAN_KRITER, " ")>
                                 [<cfloop array="#parcalar#" index="parca">
                                    '#parca#',
                                </cfloop>],
                                 
                            </cfoutput> 
                        ],
                labels: {
                    rotate: 0,
                    style:{
                        fontSize:'14px',
                        fontWeight:'bold'
                    },
                   }
                },
                yaxis: {
                title: {
                    text: 'Ortalama Puanlar (<cfoutput>#getligt.lig_name# Ligi</cfoutput>)'
                }
                },
                fill: {
                opacity: 1
                },
                tooltip: {
                y: {
                    formatter: function (val) {
                    return "$ " + val + " thousands"
                    }
                }
                }
                };

                var chart = new ApexCharts(document.querySelector("#chart"), options);
                chart.render();  
       

</script> 

</cfif>   
