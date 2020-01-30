<?php

/* display ALL errors */
error_reporting(E_ALL);

/* Include configuration */
include("config.php");

if($database_type=="sqlsrv")
	$dsn = "$database_type:server=$database_hostname;database=$database_default";
else 	
	$dsn = "$database_type:host=$database_hostname;dbname=$database_default;charset=$database_charset";

$opt = array(
		PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
		PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
);

try {
	$conn = new PDO($dsn, $database_username, $database_password, $opt);
}
catch(PDOException $e) {
	$msg="FATAL:". $e->getMessage()."\n";
	show_error($msg);
}

//print_r($_REQUEST);
//------------------------
//authorisation
if (!isset($_REQUEST['patient_id'])||
	!isset($_REQUEST['birthdate']) )
{
	show_error('no input params');
}

$patient_id=$_REQUEST['patient_id'];
$birthdate=$_REQUEST['birthdate'];

if ((strlen(trim($patient_id))==0) ||
	(strlen(trim($birthdate))==0) )
{
	show_error('empty params');
}
$r=array('patient_id'=>$patient_id
		 ,'birthdate'=>$birthdate
		);

//------------------------
//request routing
$action= isset($_REQUEST['action'])? $_REQUEST['action'] : '';

$tsql='';

if($action=='motconsu')
{
	$tsql = "select
	m.MOTCONSU_ID
	,m.PATIENTS_ID
	,DATE_CONSULTATION, REC_NAME
	 , LAB_ANT_RESULTS.NAME, LAB_ANT_RESULTS.VALUE, LAB_ANT_RESULTS.NORMS
	 , LAB_ANT_RESULTS.NORM_COMMENT, LAB_ANT_RESULTS.UNIT_NAME
	 ,LAB_ANT_RESULTS.TEST_COMMENT 
	 ,LAB_ANT_RESULTS.PATHOLOGY
	 ,(case LAB_ANT_RESULTS.PATHOLOGY
	  when 0
		then 'GREY.COLOR'
	  when 1
		then 'YELLOW.COLOR'
	  when 5
		then 'YELLOW.COLOR'
	  else
		'GREEN.COLOR'
	end) ROW_COLOR
	from MOTCONSU as m
	join PATIENTS as p on m.PATIENTS_ID=p.PATIENTS_ID
	left join LAB_ANT_RESULTS on m.MOTCONSU_ID=LAB_ANT_RESULTS.MOTCONSU_ID
	 LEFT OUTER JOIN LAB_ANT_SAMPLES LAB_ANT_SAMPLES ON LAB_ANT_SAMPLES.LAB_ANT_SAMPLES_ID = LAB_ANT_RESULTS.LAB_ANT_SAMPLES_ID 
	where 
	m.MODELS_ID=763 and
	m.PATIENTS_ID= :patient_id and
	p.NE_LE=convert(date, :birthdate, 120)
	order by DATE_CONSULTATION desc
	";
}
else if($action=='images')
{
	$tsql = "select
	m.MOTCONSU_ID
	,m.PATIENTS_ID
	,IMAGES.Images_ID
	,IMAGES.FOLDER
	,IMAGES.FileName
	,IMAGES.Descriptor
	,IMAGES.AuxFileName
	from MOTCONSU as m
	join PATIENTS as p on m.PATIENTS_ID=p.PATIENTS_ID
	join IMAGES on IMAGES.MOTCONSU_ID=m.MOTCONSU_ID
	where 
	m.MODELS_ID=763 and
	m.PATIENTS_ID= :patient_id and
	p.NE_LE=convert(date, :birthdate, 120)
	";
}
else if($action=='getimage')
{
	$image_id= isset($_REQUEST['image_id'])? $_REQUEST['image_id'] : 0;

	if (!($image_id>0) )
	{
		show_error('image_id is incorrect');
	}

	$tsql = "select
	IMAGES.FOLDER
	,IMAGES.FileName
	from MOTCONSU as m
	join PATIENTS as p on m.PATIENTS_ID=p.PATIENTS_ID
	join IMAGES on IMAGES.MOTCONSU_ID=m.MOTCONSU_ID
	where 
	m.MODELS_ID=763 and
	m.PATIENTS_ID= :patient_id and
	p.NE_LE=convert(date, :birthdate, 120) and
	IMAGES.Images_ID = :image_id
	";
	
	$r['image_id']=$image_id;
}
else{
	show_error('no action selected');
}

//------------------------

try{
	$stmt = $conn->prepare($tsql);
	$stmt -> execute($r);
	$rows=$stmt->fetchAll();
}
catch(PDOException $e) {
	$msg="FATAL:". $e->getMessage()."\n";
	show_error($msg);
}

$numRows = count($rows);
//echo "<p>$numRows Row" . ($numRows == 1 ? "" : "s") . " Returned </p>";

if($numRows>0)
{
	if($action!='getimage'){
		header("Content-type: application/json; charset=utf-8");
		echo json_encode($rows);
	}
	else{
		//header("Content-type: application/json; charset=utf-8");
		//echo json_encode($row);
		send_image($rows[0], $path_prefix);
	}
}
else 
{
	show_error('No rows returned.');
}

function send_image($row, $path_prefix){
	if(!$row)
		show_error('No image info.');
	
	$file=$path_prefix.$row['FOLDER'].$row['FileName'];

	if (!$output_data= @file_get_contents($file)) {
		$error = error_get_last();
		show_error("File open error: " . $error['message']);
	}
		
	$size=filesize($file);
	$format=pathinfo($file)['extension'];
	
	
	if(strtoupper($format)=='PDF')
		header('Content-type: application/pdf');
	else
		header("Content-Type: image/".$format."");
	
	header("Content-Length: ".$size);
	echo $output_data;
	
}

function show_error($msg){
	header("Content-type: application/json; charset=utf-8");
	echo json_encode(array('error' => $msg), JSON_FORCE_OBJECT);
	exit;
}


?>
