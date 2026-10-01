*** |  (C) 2008-2025 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

scalars
s42_reserved_fraction            Fraction of available water that is reserved for manufacturing electricity and domestic use (1) / 0.5 /

s42_irrig_eff_scenario           Scenario for irrigation efficiency     (1)       / 3 /
*                                      1: global static value
*                                      2: regional static values from CS
*                                      3: gdp driven increase

s42_irrigation_efficiency        Value of irrigation efficiency       (1)        / 0.66 /
*                                      Only if global static value is requested

s42_env_flow_scenario            EFP scenario.     (1)          / 1 /
*                                  0: don't consider environmental flows.
*                                                                          s42_env_flow_base_fraction and
*                                                                          s42_env_flow_fraction have no effect.
*                                  1: Reserve a certain fraction of available water
*                                     specified by s42_env_flow_fraction for
*                                     environmental flows.
*                                  2: Each grid cell receives its own value for
*                                     environmental flow protection based on LPJ
*                                     results and a calculation algorithm by Smakhtin 2004.
*                                                                          s42_env_flow_fraction has no effect.

* Linear fading in of environmental flow policy between startyear and targetyear
s42_efp_startyear                  Environmental flow policy start year   / 2025 /
s42_efp_targetyear                 Environmental flow policy target year  / 2050 /

s42_env_flow_base_fraction         Fraction of available water that is reserved for the environment where no EFP policy is implemented (1) / 0.05 /
s42_env_flow_fraction              Fraction of available water that is reserved for under protection policies (1) / 0.2 /
s42_pumping                        Switch to activate pumping cost settings (1) / 0 /
s42_multiplier_startyear           Year from which pumping costs multiplier will be implemented (1) / 1995 /
s42_multiplier                     multiplier to change pumping costs for sensitivity analysis takes numeric values (1)  / 0 /
;

$setglobal c42_watdem_scenario  nocc_hist
*   options:  cc        (climate change)
*             nocc      (no climate change)
*             nocc_hist (no climate change after year defined by sm_fix_cc)

table f42_wat_req_kve(t_all,j,kve) LPJmL annual water demand for irrigation per ha (m^3 per yr)
$ondelim
$include "./modules/42_water_demand/input/lpj_airrig.cs2"
$offdelim
;
$if "%c42_watdem_scenario%" == "nocc" f42_wat_req_kve(t_all,j,kve) = f42_wat_req_kve("y1995",j,kve);
$if "%c42_watdem_scenario%" == "nocc_hist" f42_wat_req_kve(t_all,j,kve)$(m_year(t_all) > sm_fix_cc) = f42_wat_req_kve(t_all,j,kve)$(m_year(t_all) = sm_fix_cc);

m_fillmissingyears(f42_wat_req_kve,"j,kve");


parameter f42_wat_req_kli(kli) Average water requirements of livestock commodities per region per tDM per year (m^3)
/
$ondelim
$include "./modules/42_water_demand/input/f42_wat_req_fao.csv"
$offdelim
/;


* Environmental flow policy
$setglobal c42_env_flow_policy  on

parameter f42_env_flows(t_all,j) Environmental flow requirements from LPJ and Smakhtin algorithm (mio. m^3)
/
$ondelim
$include "./modules/42_water_demand/input/lpj_envflow_grper.cs2"
$offdelim
/;
$if "%c42_watdem_scenario%" == "nocc" f42_env_flows(t_all,j) = f42_env_flows("y1995",j);
$if "%c42_watdem_scenario%" == "nocc_hist" f42_env_flows(t_all,j)$(m_year(t_all) > sm_fix_cc) = f42_env_flows(t_all,j)$(m_year(t_all) = sm_fix_cc);
m_fillmissingyears(f42_env_flows,"j");

* Set-switch for countries affected by EFP
* Default: all iso countries selected
sets
  EFP_countries(iso) countries to be affected by EFP / AUT, BEL, BGR, HRV, CYP, CZE, DNK, EST, FIN, FRA, DEU, GRC, HUN, IRL, ITA, LVA, LTU, LUX, MLT, NLD, POL, PRT, ROU, SVK, SVN, ESP, SWE, GBR /
;


* Costs of pumping are calculated for India as per methodology in forthcoming paper by Singh et.al.
parameter
f42_pumping_cost(t_all,i) Cost of pumping irrigation water (USD17MER per m^3)
/
$ondelim
$include "./modules/42_water_demand/input/f42_pumping_cost.cs4"
$offdelim
/
;
