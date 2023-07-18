<script src="https://code.highcharts.com/highcharts.js"></script>
<script src="https://code.highcharts.com/modules/data.js"></script>
<script src="https://code.highcharts.com/modules/drilldown.js"></script>
<script src="https://code.highcharts.com/modules/exporting.js"></script>
<script src="https://code.highcharts.com/modules/export-data.js"></script>
<script src="https://code.highcharts.com/modules/accessibility.js"></script>
<script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>

<div class="col-md-12 mb-2">
    <div class="header text-center font-weight-bold">
        Liglerin Ortalama Puanları
    </div>
    <div class="header text-right font-weight-bold d-none redirect">
        <button class="btn border round" onclick="get_detail_return()"> Ana Grafiğe Dön</button> 
    </div>
    <div id="Lig_Chart"></div>
</div>


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
        align:'right',
        text: '<span style="font-size:12px">Barların Üzerine Tıklayarak Lig Bazlı Detay Görüntüleyebilirsiniz</span>'
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
                            <cfif len(attributes.ay_id)>
                                AND BP.AY_ID =#attributes.ay_id#
                            </cfif>
                        ) AS ORTALAMA_PUAN, 
                        LIG_NAME 
                        FROM BAYILIGI_PUAN BP
                        LEFT JOIN COMPANY C ON C.COMPANY_ID = BP.COMPANY_ID
                        LEFT JOIN SETUP_LIG SL ON SL.LIG_ID = C.LIG_ID
                        WHERE LIG_NAME IS NOT NULL AND SL.LIG_ID=#LIG_ID#
                        <cfif len(attributes.ay_id)>
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
                 $(`.redirect`).addClass('d-none');  
            }
        });     
    }
</script> 
