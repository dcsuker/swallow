package com.cy.example.controller;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.activiti.engine.repository.Deployment;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.cy.example.carrier.PageCa;
import com.cy.example.service.IWorkFlowService;

@Controller
@RequestMapping("/system/workflow")
public class WorkFlowController extends BaseController {

	private final Logger logger = LoggerFactory
			.getLogger(this.getClass());
	
	@Autowired
	private IWorkFlowService workFlowService;
	
	@RequestMapping("/deploy")
	@ResponseBody
	public String deploy(@RequestParam("name") String name,  
	        @RequestParam("file") MultipartFile file) {
		File toolFile = null;
		workFlowService.deploy(toolFile, name);
		Map<String, Object> map = new HashMap<String, Object>();
		
		return "workflow/deployManage";
	}
	
	@RequestMapping("/findAll")
	@ResponseBody
	public Map<String, Object> findAll(@ModelAttribute("page")PageCa page) {
		List<Deployment> list = workFlowService.getDeploymentList(page);
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("rows", list);
		map.put("total", list.size());
		
		return map;
	}

	@RequestMapping("/searchData")
	@ResponseBody
	public Map<String, Object> searchData(
			@ModelAttribute("deployment") Deployment deployment,
			@ModelAttribute("page") PageCa page) {
		Map<String, Object> map = new HashMap<String, Object>();
		List<Deployment> list = workFlowService.searchAll(
				deployment, page);
		map.put("rows", list);
		map.put("total", list.size());
		return map;
	}
	
}
