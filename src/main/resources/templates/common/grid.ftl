<#macro grid controller title fields rownumbers="true" singleSelect="true" width="1000px" height="500px" ed_width="350px" ed_height="330px">
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Auto Height for Tabs - jQuery EasyUI Demo</title>
    <link rel="stylesheet" type="text/css" href="../lib/easyui/themes/material/easyui.css">
    <link rel="stylesheet" type="text/css" href="../lib/easyui/themes/icon.css">
    <link href="../lib/toastr/toastr.css" rel="stylesheet"/>
    <script type="text/javascript" src="../lib/easyui/jquery.min.js"></script>
    <script type="text/javascript" src="../lib/easyui/jquery.easyui.min.js"></script>
    <script type="text/javascript" src="../lib/easyui/locale/easyui-lang-zh_CN.js"></script>
    <script type="text/javascript" src="../lib/layer/layer.js"></script>
    <script type="text/javascript" src="../lib/toastr/toastr.js"></script>
    <script type="text/javascript" src="../js/map.js"></script>
    <script language="javascript">
    	var map =new Map();
		var editMap =new Map();
		//操作类型,1代表添加操作,2代表编辑操作
		var operation = 1;
		$(function(){
		    <#list fields?split(",") as x>  
		    	<#if (x_index !=0)>
			        <#list x?split(":") as y>
			         	<#if (y_index ==0)>
							var key = "${y}";
						</#if>
						map.put(key,"textbox");
						editMap.put(key,"textbox");
			        </#list> 
		        </#if>
		    </#list>
		});  
		
		
		function deleteData(){
			var row = $('#dg').datagrid('getSelected');
            if (row){
            	//删除行数据
				layer.confirm('确定要删除该数据吗？', {
				  	btn: ['删除','取消'] //按钮
				}, function(){
				  	$.ajax({ //使用ajax与服务器异步交互
		                url:"${controller}delete?s="+new Date().getTime(), //后面加时间戳，防止IE辨认相同的url，只从缓存拿数据
		                type:"POST",
		                data: {id:row.id}, 
		                dataType:"json",
		                error:function(XMLHttpRequest,textStatus,errorThrown){
		                	toastr.error('网络连接失败！');
		                }, //错误提示
		
		                success:function(data){ //data为交互成功后，后台返回的数据
		                    var flag =data.flag;//服务器返回标记
		                    if(flag){
		                    	layer.closeAll('dialog');
		                    	toastr.success('删除成功！');
		                    	$('#dg').datagrid('reload');
		                    }else {
		                    	toastr.error('删除失败！');
							}
		                }
		            });
				});
				
            }else{
				toastr.warning('在操作之前请先选中行！');
            }
		}
		
		function searchData(){
			var json = "";
			for(var i = 0;i<map.size();i++){
				json += map.key(i)+"="+getValues("tb_",map.key(i))+"&";
				//var arr = $("#tb_"+map.key(i)).attr("class");
				//alert(arr);
			}
			json = json.substring(0,json.length-1);
			alert(json);
			$.ajax({ //使用ajax与服务器异步交互
                url:"${controller}searchData?s="+new Date().getTime(), //后面加时间戳，防止IE辨认相同的url，只从缓存拿数据
                type:"POST",
                data: json, 
                dataType:"json",
                error:function(XMLHttpRequest,textStatus,errorThrown){
                	toastr.error('网络连接失败！');
                }, //错误提示

                success:function(data){ //data为交互成功后，后台返回的数据
					$('#dg').datagrid('loadData',data);  
					toastr.success('查询成功！共查询到'+data.total+'条数据！');
                }
            });
		}
		
		
		//添加数据
		function addData(){
            operation = 1;
            //清空编辑框的值
            for(var i = 0;i<map.size();i++){
				setValues(map.key(i),'');
			}
            $('#dlg').dialog("open");
		}
		
		//编辑数据
		function editData(){
			var row = $('#dg').datagrid('getSelected');
            if (row){
            	operation = 2;
            	var jsonStr = JSON.stringify(row);
            	var reg = new RegExp('"','g');
            	jsonStr = jsonStr.substring(1,jsonStr.length-1).replace(reg,'');
            	var attr = jsonStr.split(",");
            	//console.log(attr);
            	for(var i=0;i<attr.length;i++){
            		var attr2 =  attr[i].split(":")
            		for(var j=0;j<attr2.length;j++){
            			if(attr2[0] == "id"){
            				$("#ed_id").val(attr2[1]);
            				continue;
            			}
            			<#nested>
            			setValues(attr2[0],attr2[1]);
            		}
            	}
            	$('#dlg').dialog("open");
            	
            }else{
				toastr.warning('在操作之前请先选中行！');
            }
		}
		
		//编辑之后的确定按钮事件
		function dlgBtnClick(){
			var url;
			var json = "";
			for(var i = 0;i<editMap.size();i++){
				json += editMap.key(i)+"="+getValues("ed_",editMap.key(i))+"&";
			}
			if(operation == 1){
				url = "${controller}add?s="+new Date().getTime();
				json = json.substring(0,json.length-1);
			}else if(operation == 2){
				url = "${controller}update?s="+new Date().getTime();
				json += "id="+$("#ed_id").val();
			}
			alert(json);
			$.ajax({ //使用ajax与服务器异步交互
                url:url, //后面加时间戳，防止IE辨认相同的url，只从缓存拿数据
                type:"POST",
                data: json, 
                dataType:"json",
                error:function(XMLHttpRequest,textStatus,errorThrown){
                	toastr.error('网络连接失败！');
                }, //错误提示

                success:function(data){ //data为交互成功后，后台返回的数据
					var flag =data.flag;//服务器返回标记
                    if(flag){
                    	$('#dlg').dialog("close");
                    	toastr.success('添加成功！');
                    	$('#dlg').dialog("close");
                    	$('#dg').datagrid('reload');
                    }else {
                    	toastr.error('删除失败！');
					}
                }
            });
			
		}

		//实现双击编辑操作
		function onDblClickRow(index,field,value){
			//toastr.info('双击操作！');
			editData();
		}
		
		
		
		//根据id隐藏查询框搜索条件
		function hideQueryElem(id){
			//$("#tb_"+id).parent().hide();
			$("#tb_"+id).parent().remove();
			map.remove(id);
		}
		
		//根据id修改查询框输入框类型
		function modifyQueryElem(id,type){
			if(type == "datebox" || type == "numberbox" || type == "datetimebox"){
				var parent = $("#tb_"+id).parent();
				$("#tb_"+id).textbox("destroy");
				var children = $("<input id='tb_"+id+"' type= 'text' class='easyui-"+type+"' style='width:120px'>");
				parent.append(children);
				$.parser.parse(parent);
				map.put(id,type);
			}
		}
		
		//根据id修改查询框输入框类型
		/*
		loc:控件位置，值为tb_和ed_，分别代表工具栏和查询栏
		
		*/
		function modifyElem(loc,id,type,data){
			if(type == "combobox" || type == "combotree"){
				var parent = $("#"+loc+id).parent();
				$("#"+loc+id).textbox("destroy");
				var children = $("<input id='"+loc+id+"' type= 'text' class='easyui-"+type+"' style='width:120px' valueField='id' textField='text' panelHeight='auto'>");
				parent.append(children);
				$.parser.parse(parent);
				map.put(id,type);
				data = JSON.parse(data);
				if(type == "combobox"){
					//console.log(data);
					$("#"+loc+id).combobox("loadData",data);
				}else if(type == "combotree"){
					$("#"+loc+id).combotree("loadData",data);
				}
			}
		}
		
		//根据id隐藏编辑框搜索条件
		function hideEditElem(id){
			$("#ed_"+id).parent().remove();
			editMap.remove(id);
		}
		
		function addEditElem(id,name){
			var parent = $("#dlg_box");
			var childen = $("<span>"+name+": <input id='ed_"+id+"' name='"+id+"' class='easyui-textbox' style='width:120px;margin-top:10px'></span></br></br>");
			parent.append(childen);
			$.parser.parse(childen);
			editMap.put(id,"textbox");
		}
		
		//根据id修改编辑框输入框类型
		function modifyEditElem(id,type){
			if(type == "datebox" || type == "combobox" || type == "combotree" || type == "numberbox" ||
			 	type == "datetimebox"){
				var parent = $("#ed_"+id).parent();
				$("#ed_"+id).textbox("destroy");
				var children = $("<input id='ed_"+id+"' type= 'text' class='easyui-"+type+"' style='width:120px'>");
				parent.append(children);
				$.parser.parse(parent);
				editMap.put(id,type);
			}
		}
		
		//根据id设置编辑框是否为只读
		function modifyEditEle(id,type){
			
		}
		
		function setValues(key,value){
			if(map.contains(key)>-1){
				var type = map.get(key);
				switch (type)
				{
					case "combobox":
					  $("#ed_"+key).combobox('select',value);//$("#tb_"+key)是我自定义的格式
					  break;
					case "numberbox":
					  $("#ed_"+key).numberbox('setValue',value);
					  break;
					case "datebox":
					  $("#ed_"+key).datebox('setValue',value);
					  break;
					case "datetimebox":
					  $("#ed_"+key).datetimebox('setValue',value);
					  break;
					case "combotree":
					  $("#ed_"+key).combotree('select',value);
					  break;
					case "textbox":
					  $("#ed_"+key).textbox('setValue',value);
					  break;
				}
			}
		}
		
		function getValues(loc,key){
			var returnVal = "";
			if(map.contains(key)>-1){
				var type = map.get(key);
				switch (type)
				{
					case "combobox":
					  returnVal = $("#"+loc+key).combobox('getValue');//$("#tb_"+key)是我自定义的格式
					  break;
					case "numberbox":
					  returnVal = $("#"+loc+key).numberbox('getValue');
					  break;
					case "datebox":
					  returnVal = $("#"+loc+key).datebox('getValue');
					  break;
					case "datetimebox":
					  returnVal = $("#"+loc+key).datetimebox('getValue');
					  break;
					case "combotree":
					  returnVal = $("#"+loc+key).combotree('getValue');
					  break;
					case "textbox":
					  returnVal = $("#"+loc+key).textbox('getValue');
					  break;
				}
			}
			return returnVal;
		}
	
	
		
	</script>
</head>
<body>
	<table id="dg" class="easyui-datagrid" title="${title}信息管理" style="width:${width};height:${height}"
            data-options="rownumbers:${rownumbers},singleSelect:${singleSelect},
            url:'${controller}findAll',method:'get',toolbar:'#tb,#ft',pagination:'true',nowrap:'true',
            onDblClickRow: onDblClickRow">
        <thead>
            <tr>
                <#list fields?split(",") as x>  
			        <#list x?split(":") as y>
			         	<#if (y_index ==0)>
			         		<#if ("${y}" == "id")>
								<th data-options="field:'${y}',width:200,hidden:true">
							<#else>	
								<th data-options="field:'${y}',width:200">
							</#if>
						<#else>
							${y}</th>
						</#if>
			        </#list> 
			    </#list>  
            </tr>
        </thead>
    </table>
    <!--查询栏-->	
    <div id="tb" style="padding:10px 10px;">
        <#list fields?split(",") as x>  
        	<#if (x_index !=0)>
		        <#list x?split(":")?reverse  as y>
		         	<#if (y_index ==0)>
		         		<#if ("${y}" != "id")>
							<span>&emsp;${y}:
						</#if>
					<#else>
						<#if ("${y}" != " ")>
							<input id="tb_${y}" name="${y}" class="easyui-textbox" style="width:120px"></span>
						</#if>
					</#if>
		        </#list> 
		    </#if>
	    </#list>
	    &emsp;<a href="#" class="easyui-linkbutton" iconCls="icon-search" onclick="searchData()">查询</a>
    </div>
    <!--操作栏-->
    <div id="ft" style="padding:2px 5px;">
        <a href="#" class="easyui-linkbutton" iconCls="icon-add" plain="true" onclick="addData()">添加</a>
        <a href="#" class="easyui-linkbutton" iconCls="icon-edit" plain="true" onclick="editData()">编辑</a>
        <a href="#" class="easyui-linkbutton" iconCls="icon-remove" plain="true" onclick="deleteData()">删除</a>
    </div>
    <!--编辑框-->
    <div id="dlg" class="easyui-dialog" title="编辑${title}信息" style="width:${ed_width};height:${ed_height};padding:10px"
            data-options="
                buttons: [{
                    text:'确定',
                    iconCls:'icon-ok',
                    handler:function(){
                       dlgBtnClick();
                    }
                },{
                    text:'取消',
                    iconCls:'icon-cancel',
                    handler:function(){
                        $('#dlg').dialog('close');
                    }
                }],
                minimizable:true,
                maximizable:true,
                closed:true
            ">
            <div id="dlg_box" style="margin-left:50px;margin-top:20px">
            	<input type="text" id="ed_id" style="display:none">
		        <#list fields?split(",") as x>  
		        	<#if (x_index !=0)>
				        <#list x?split(":")?reverse  as y>
				         	<#if (y_index ==0)>
				         		<#if ("${y}" != "id")>
									<span>${y}:
								</#if>
							<#else>
								<#if ("${y}" != " ")>
									<input id="ed_${y}" name="${y}" class="easyui-textbox" style="width:120px;margin-top:10px"></span></br></br>
								</#if>
							</#if>
				        </#list> 
				    </#if>
			    </#list>
		    <div>
    </div>
</body>
</html>
</#macro>